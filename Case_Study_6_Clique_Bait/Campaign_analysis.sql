/*Generate a table that has 1 single row for every unique visit_id record 
and has the following columns:
	
	- user_id
	- visit_id
	- visit_start_time: the earliest event_time for each visit
	- page_views: count of page views for each visit
	- cart_adds: count of product cart add events for each visit
	- purchase: 1/0 flag if a purchase event exists for each visit
	- campaign_name: map the visit to a campaign if the visit_start_time falls 
		between the start_date and end_date
	- impression: count of ad impressions for each visit
	- click: count of ad clicks for each visit
	- (Optional column) cart_products: a comma separated text value with products added 
		to the cart sorted by the order they were added to the cart 
		(hint: use the sequence_number)

Use the subsequent dataset to generate at least 5 insights for the Clique Bait team - 
bonus: prepare a single A4 infographic that the team can use for their management reporting 
sessions, be sure to emphasise the most important points from your findings.

Some ideas you might want to investigate further include:

	- Identifying users who have received impressions during each campaign period 
	and comparing each metric with other users who did not have an impression event
	- Does clicking on an impression lead to higher purchase rates?
	- What is the uplift in purchase rate when comparing users who click on a campaign 
	impression versus users who do not receive an impression? 
	- What if we compare them with users who just an impression but do not click?
	- What metrics can you use to quantify the success or failure of each campaign compared 
	to eachother?
*/
-- create table as requirements 
create table event_summary as 
with purchase as (
	select distinct visit_id as purchase_id 
	from events
	where event_type = 3
)
select user_id, visit_id, min(event_time) as visit_start_time,
sum(case when event_type = 1 then 1 else 0 end) as page_views,
sum(case when event_type =2 then 1 else 0 end ) as cart_adds,
case when purchase_id is not null then '1' else '0' end as purchase,
(case when min(event_time) between '2020-01-01 00:00:00' and '2020-01-14 00:00:00' then 'BOGOF - Fishing For Compliments'
	when min(event_time) between '2020-01-15 00:00:00' and '2020-01-28 00:00:00' then '25% Off - Living The Lux Life'
	when min(event_time) between '2020-02-01 00:00:00' and '2020-03-31 00:00:00' then 'Half Off - Treat Your Shellf(ish)'
end)as campaign_name,
sum(case when event_type =4 then 1 else 0 end ) as impression,
sum(case when event_type = 5 then 1 else 0 end ) as click,
string_agg (case when event_type =2 and product_id is not null then page_name else null end,', ') as cart_products
from events as e
join users as u on e.cookie_id = u.cookie_id
left join purchase on purchase_id = visit_id 
join page_hierarchy as ph on e.page_id = ph.page_id
group by visit_id, user_id, purchase_id 
order by user_id

--Identifying users who have received impressions during each campaign period and comparing 
-- each metric with other users who did not have an impression event
with received_impression_during_campaign as (
	select 
	count(distinct user_id) as impression_dur_camp
	from event_summary
	where impression >0 and campaign_name is not null
),
received_impression_but_not_clicked as (
	select count(distinct user_id) as impression_dur_camp_not_clicked
	from event_summary
	where impression >0 and click = 0 and campaign_name is not null
),
not_received_impression_during_campaing as (
	select count(distinct user_id) as not_impression_dur_camp
	from event_summary
	where campaign_name is not null
	and user_id not in (
		select user_id
		from event_summary
		where impression > 0)
)
select impression_dur_camp, not_impression_dur_camp, impression_dur_camp_not_clicked
from received_impression_during_campaign
cross join received_impression_but_not_clicked 
cross join not_received_impression_during_campaing;
/* 
The campaign results show the following:
	- 416 users received impressions, 57 did not, and 128 received impression but not clicked ads
	- Impression Rate: 416/ (416+57) *100= 88.2 %
	This means 88.2% of the target audience was reached by the ad.
	- Click Rate: 100 −(128/416)×100 = 69.5%
	This means 69.5% of users who saw the ad clicked on it.
Overall, the campaign was highly effective in both reaching a large audience 
and driving engagement.
*/

-- Does clicking on an impression lead to higher purchase rates?
with received_impression_during_campaign as (
	select 
	count(distinct user_id) as impression
	from event_summary
	where impression >0 and campaign_name is not null
),
received_impression_but_not_clicked as (
	select count(distinct user_id) as impression_not_clicked
	from event_summary
	where impression >0 and click = 0 and campaign_name is not null
),
total_purchase_when_click_ads as (
	select count(distinct user_id) as purchase_when_click 
	from event_summary
	where campaign_name is not null and purchase = '1' and click =1
),
total_purchase_without_click_ads as (
	select count(distinct user_id) as purchase_wo_click
	from event_summary
	where campaign_name is not null and purchase = '1' 
	and user_id not in (
		select user_id
		from event_summary
		where click =1
	)
)
select (impression- impression_not_clicked) as impression_and_click,
	purchase_when_click, impression_not_clicked, purchase_wo_click,
	round(100.0*purchase_when_click/(impression- impression_not_clicked),2)as purchase_rate_when_click,
	round(100.0*purchase_wo_click/impression_not_clicked,2)as purchase_rate_wo_click	
from total_purchase_when_click_ads
cross join total_purchase_without_click_ads
cross join received_impression_but_not_clicked
cross join received_impression_during_campaign;

/*
- Purchase rate when click = 118.75%
Since the purchase rate exceeds 100%, it's possible that some users made multiple purchases 
after clicking, so this could represent repeat purchases.
- Purchase rate without click = 69.53% 
The data indicates that clicking on an ad leads to a higher purchase rate (118.75%) compared to 
not clicking (69.5%). This suggests that users who engage with the ad by clicking are more likely 
to make a purchase, possibly even multiple purchases.
*/

-- What is the uplift in purchase rate when comparing users who click on a campaign 
-- impression versus users who do not receive an impression? 
with total_purchase_when_click_ads as (
	select count(distinct user_id) as purchase_when_click 
	from event_summary
	where campaign_name is not null and purchase = '1' and click =1
),
not_received_impression_but_purchase as (
	select count(distinct user_id) as not_impression_but_purchase
	from event_summary
	where campaign_name is not null and purchase = '1'
	and user_id not in (
		select user_id
		from event_summary
		where impression > 0)
),
not_received_impression as (
	select count(distinct user_id) as not_impression_dur_camp
	from event_summary
	where campaign_name is not null
	and user_id not in (
		select user_id
		from event_summary
		where impression > 0)
),
received_impression_during_campaign as (
	select 
	count(distinct user_id) as impression
	from event_summary
	where impression >0 and campaign_name is not null
),
received_impression_but_not_clicked as (
	select count(distinct user_id) as impression_not_clicked
	from event_summary
	where impression >0 and click = 0 and campaign_name is not null
),	
combine_tables as (
	select round(100.0*purchase_when_click/(impression-impression_not_clicked),2)as purchase_rate_when_click,
	round(100.0*not_impression_but_purchase/not_impression_dur_camp ,2)as purchase_rate_when_no_impression
	from total_purchase_when_click_ads
	cross join not_received_impression_but_purchase
	cross join not_received_impression
	cross join received_impression_during_campaign
	cross join received_impression_but_not_clicked
)
select purchase_rate_when_click,purchase_rate_when_no_impression,
round(100.0*(purchase_rate_when_click-purchase_rate_when_no_impression)/purchase_rate_when_no_impression ,2) as uplift
from combine_tables; 
/* During campaign, purchase rate when user receive impression and click ads is 118.75%,
while purchase rate of user not receive any impression is 77.19%.
There is a 61.19% uplift in the purchase rate for users who clicked on a campaign 
impression compared to users who did not receive an impression. 
This indicates that users who saw and interacted with the ad were significantly 
more likely to make a purchase.
*/

-- What if we compare them with users who just an impression but do not click?
with total_purchase_when_click_ads as (
	select count(distinct user_id) as purchase_when_click 
	from event_summary
	where campaign_name is not null and purchase = '1' and click =1
),
received_impression_during_campaign as (
	select 
	count(distinct user_id) as impression
	from event_summary
	where impression >0 and campaign_name is not null
),
received_impression_but_not_clicked as (
	select count(distinct user_id) as impression_not_clicked
	from event_summary
	where impression >0 and click = 0 and campaign_name is not null
),	
total_purchase_without_click_ads as (
	select count(distinct user_id) as purchase_wo_click
	from event_summary
	where campaign_name is not null and purchase = '1' 
	and user_id not in (
		select user_id
		from event_summary
		where click =1
	)
),
combine_tables as (
	select round(100.0*purchase_when_click/(impression-impression_not_clicked),2)as purchase_rate_when_click,
	round(100.0*purchase_wo_click/impression_not_clicked ,2)as purchase_rate_when_impression_no_click
	from total_purchase_when_click_ads
	cross join received_impression_during_campaign
	cross join received_impression_but_not_clicked
	cross join total_purchase_without_click_ads
)
select purchase_rate_when_click,purchase_rate_when_impression_no_click,
round(100.0*(purchase_rate_when_click-purchase_rate_when_impression_no_click)/purchase_rate_when_impression_no_click ,2) as uplift
from combine_tables
/*
The substantial uplift in purchase rate (70.79%) highlights that clicking on the ad significantly
increases the likelihood of making a purchase compared to simply viewing the ad without engaging. 
This insight can be valuable in designing future campaigns to focus more on strategies that drive 
ad clicks (such as more compelling calls to action or improved targeting)
*/

-- What metrics can you use to quantify the success or failure of each campaign compared 
-- to eachother?
/*
1. IMPRESSION RATE: Measures how well the ad was delivered to the intended audience.

Impression Rate = 100*Users who received impressions/Total audience

2. CLICK THROUGH RATE (CTR): Shows how effectively the ad encouraged users to take action.
A higher CTR suggests that the ad was engaging.

CTR = 100 * Users who clicked the ad / Users who received impressions

3. CONVERSION RATE: Measures the percentage of users who made a purchase after receiving an 
impression.

Conversion Rate = 100 * Total purchases / Total users who received impressions

4. PURCHASE RATE BY SEGMENT (CLICK VS NO CLICK): Compares the purchase rate for users who 
clicked the ad to those who didn’t. This helps evaluate how essential clicks are for conversion.

Purchase Rate (Clicked) = 100* Purchases after clicking/ Users who clicked

Purchase Rate (No Click) = 100* Purchases w/o clicking / Users who didn’t click but received impressions
