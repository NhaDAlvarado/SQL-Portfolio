/* Which areas of the business have the highest negative impact 
in sales metrics performance in 2020 for the 12 week before and 
after period?
	- region
	- platform
	- age_band
	- demographic
	- customer_type
Do you have any further recommendations for Danny’s team at Data Mart 
or any interesting insights based off this analysis?
*/

-------REGIONS-------
with week_number_of_2020_06_15 as (
	select distinct week_number as week_of_2020_06_15
	from clean_weekly_sales
	where week_date = '2020-06-15'
),
twelve_weeks_before as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15 -12) 
		and (week_of_2020_06_15 -1)
),
twelve_weeks_after as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15)
		and (week_of_2020_06_15 +11)
),
combine_with_calander_year as (
	select region,
	sum(case when week_date in (select * from twelve_weeks_before) then sales
		end) as sale_12_weeks_before,
	sum(case when week_date in (select * from twelve_weeks_after) then sales
		end) as sale_12_weeks_after
	from clean_weekly_sales
	group by region
)
select *, 
	(sale_12_weeks_after- sale_12_weeks_before) as growth_in_values,
	round((sale_12_weeks_after- sale_12_weeks_before)*100.0/sale_12_weeks_after,2) as growth_in_percentage
from combine_with_calander_year
order by growth_in_percentage;

/* Based on the results, the most significant negative impact has occurred 
in ASIA, where negative growth has been observed since June 15, 2020. 
This decline is attributed to a lack of familiarity with sustainable 
products, as many consumers in the region tend to prioritize convenience, 
such as the continued use of plastic bags.
*/

-------PLATFORMS-------
with week_number_of_2020_06_15 as (
	select distinct week_number as week_of_2020_06_15
	from clean_weekly_sales
	where week_date = '2020-06-15'
),
twelve_weeks_before as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15 -12) 
		and (week_of_2020_06_15 -1)
),
twelve_weeks_after as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15)
		and (week_of_2020_06_15 +11)
),
combine_with_calander_year as (
	select platform,
	sum(case when week_date in (select * from twelve_weeks_before) then sales
		end) as sale_12_weeks_before,
	sum(case when week_date in (select * from twelve_weeks_after) then sales
		end) as sale_12_weeks_after
	from clean_weekly_sales
	group by platform
)
select *, 
	(sale_12_weeks_after- sale_12_weeks_before) as growth_in_values,
	round((sale_12_weeks_after- sale_12_weeks_before)*100.0/sale_12_weeks_after,2) as growth_in_percentage
from combine_with_calander_year
order by growth_in_percentage;

/* Based on the results, RETAIL platforms have experienced the most negative 
impact, largely due to their traditional mindset—such as asking customers 
to use bags or driving to physical stores. 
In contrast, Shopify has seen the most growth since June 15, 2020, 
as it emphasizes sustainability by using less plastic and optimizing 
deliveries, waiting until trucks are nearly full before dispatching.
*/

-------AGE BANDS-------
with week_number_of_2020_06_15 as (
	select distinct week_number as week_of_2020_06_15
	from clean_weekly_sales
	where week_date = '2020-06-15'
),
twelve_weeks_before as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15 -12) 
		and (week_of_2020_06_15 -1)
),
twelve_weeks_after as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15)
		and (week_of_2020_06_15 +11)
),
combine_with_calander_year as (
	select age_band,
	sum(case when week_date in (select * from twelve_weeks_before) then sales
		end) as sale_12_weeks_before,
	sum(case when week_date in (select * from twelve_weeks_after) then sales
		end) as sale_12_weeks_after
	from clean_weekly_sales
	group by age_band
)
select *, 
	(sale_12_weeks_after- sale_12_weeks_before) as growth_in_values,
	round((sale_12_weeks_after- sale_12_weeks_before)*100.0/sale_12_weeks_after,2) as growth_in_percentage
from combine_with_calander_year
order by growth_in_percentage;

/* The "UNKNOWN" age band has experienced the most negative growth, 
primarily because its lack of identifiable data makes it challenging 
to analyze trends or behaviors accurately. Without specific age-related 
insights, it's difficult to tailor strategies for improvement or 
make informed decisions. 
As a result, focus shifts to the next group showing negative 
growth—the MIDDLE AGED demographic. This group has exhibited notable 
declines, likely due to changing consumer preferences or habits that 
haven’t been adequately addressed, making it crucial to analyze their 
needs and behaviors more closely 
*/

-------DEMOGRAPHIC-------
with week_number_of_2020_06_15 as (
	select distinct week_number as week_of_2020_06_15
	from clean_weekly_sales
	where week_date = '2020-06-15'
),
twelve_weeks_before as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15 -12) 
		and (week_of_2020_06_15 -1)
),
twelve_weeks_after as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15)
		and (week_of_2020_06_15 +11)
),
combine_with_calander_year as (
	select demographic,
	sum(case when week_date in (select * from twelve_weeks_before) then sales
		end) as sale_12_weeks_before,
	sum(case when week_date in (select * from twelve_weeks_after) then sales
		end) as sale_12_weeks_after
	from clean_weekly_sales
	group by demographic
)
select *, 
	(sale_12_weeks_after- sale_12_weeks_before) as growth_in_values,
	round((sale_12_weeks_after- sale_12_weeks_before)*100.0/sale_12_weeks_after,2) as growth_in_percentage
from combine_with_calander_year
order by growth_in_percentage;

/* The result shows the "UNKNOWN" demographic with the highest negative 
growth (-0.55), likely due to incomplete data, making it hard to develop 
targeted strategies. Improving data collection could reduce this trend.

The "COUPLES" demographic also has negative growth (-0.3), possibly 
due to prioritizing convenience over sustainability in joint household 
decisions. Targeted campaigns promoting the benefits of sustainable products, 
such as eco-friendly packaging or long-term savings, could help shift their 
behavior and improve engagement with sustainability efforts.
*/

-------CUSTOMER TYPE-------
with week_number_of_2020_06_15 as (
	select distinct week_number as week_of_2020_06_15
	from clean_weekly_sales
	where week_date = '2020-06-15'
),
twelve_weeks_before as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15 -12) 
		and (week_of_2020_06_15 -1)
),
twelve_weeks_after as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15)
		and (week_of_2020_06_15 +11)
),
combine_with_calander_year as (
	select customer_type,
	sum(case when week_date in (select * from twelve_weeks_before) then sales
		end) as sale_12_weeks_before,
	sum(case when week_date in (select * from twelve_weeks_after) then sales
		end) as sale_12_weeks_after
	from clean_weekly_sales
	group by customer_type
)
select *, 
	(sale_12_weeks_after- sale_12_weeks_before) as growth_in_values,
	round((sale_12_weeks_after- sale_12_weeks_before)*100.0/sale_12_weeks_after,2) as growth_in_percentage
from combine_with_calander_year
order by growth_in_percentage;

/* The report shows "EXISTING" customers with the highest negative growth (-0.51),
indicating that current customers may be resistant to the switch toward sustainability. 
Re-engaging this group with loyalty incentives or education on the benefits of sustainable 
products could help reduce this decline.

"GUEST" customers also experienced negative growth (-0.46), suggesting a lack of 
long-term engagement. Offering personalized promotions or seamless sign-up options might 
encourage guest users to return and adopt sustainable choices.

In contrast, "NEW" customers show positive growth (+0.68), suggesting they are more open 
to sustainable products. This indicates that the data mart's sustainability efforts resonate 
well with first-time buyers, and focusing on this segment could drive further growth.
*/
