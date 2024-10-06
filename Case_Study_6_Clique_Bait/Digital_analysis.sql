/*
Using the available datasets - answer the following questions using a single query 
for each one:
	1. How many users are there?
	2. How many cookies does each user have on average?
	3. What is the unique number of visits by all users per month?
	4. What is the number of events for each event type?
	5. What is the percentage of visits which have a purchase event?
	6. What is the percentage of visits which view the checkout page but do not 
		have a purchase event?
	7. What are the top 3 pages by number of views?
	8. What is the number of views and cart adds for each product category?
	9. What are the top 3 products by purchases?
*/

-- 1. How many users are there?
select count(distinct user_id) as no_of_users
from users;

-- 2. How many cookies does each user have on average?
with cookie_per_user as (
	select user_id, count(distinct cookie_id) as no_of_cookie_per_user 
	from users
	group by user_id
)
select round (sum(no_of_cookie_per_user)/count(user_id),2) as avg_cookies
from cookie_per_user ;

-- 3. What is the unique number of visits by all users per month?
select to_char(event_time, 'MM-YYYY') as month_year,
	count(distinct visit_id) as no_of_visits
from events
group by month_year
order by month_year;

-- 4. What is the number of events for each event type?
select event_name, count(*) as no_of_events 
from events as e
join event_identifier as ei on e.event_type = ei.event_type
group by event_name
order by event_name;

-- 5. What is the percentage of visits which have a purchase event?
with total_no_of_visit as (
	select count(distinct visit_id) as total_visit
	from events
),
no_of_purchase_events as (
	select event_name, count(distinct visit_id) as no_of_events 
	from events as e
	join event_identifier as ei on e.event_type = ei.event_type 
	where event_name ='Purchase' 
	group by event_name
)
select event_name, 
	round(no_of_events*100.0/total_visit,2) as percentage
from no_of_purchase_events
cross join total_no_of_visit;

-- 6. What is the percentage of visits which view the checkout page but do not 
-- have a purchase event?
with visit_with_checkout_view_and_confirm_purchase as (
	select visit_id, ph.page_name, ei.event_name,
	count(*) over (partition by visit_id) as no_of_visit
	from events as e
	join event_identifier as ei on e.event_type = ei.event_type 
	join page_hierarchy as ph on ph.page_id = e.page_id 
	where page_name = 'Checkout' or page_name = 'Confirmation'
	order by visit_id, page_name
), 
visit_checkout_but_no_purchase as (
	select count(distinct visit_id) as no_of_visit_checkout_no_purchase
	from visit_with_checkout_view_and_confirm_purchase
	where no_of_visit = 1
),
total_num_of_visit as (
	select count(distinct visit_id) as total_visit
	from events
)
select round(100.0*no_of_visit_checkout_no_purchase/total_visit,2) as percentage_checkout_view_but_no_purchase
from visit_checkout_but_no_purchase
cross join total_num_of_visit;

-- 7. What are the top 3 pages by number of views?
select ph.page_name, count(visit_id) as num_of_views
from events as e
join event_identifier as ei on e.event_type = ei.event_type 
join page_hierarchy as ph on ph.page_id = e.page_id 
group by ph.page_name
order by num_of_views desc
limit 3;

-- 8. What is the number of views and cart adds for each product category?
select ph.product_category, 
sum(case when ei.event_name = 'Add to Cart' then 1 else 0 end) as total_add_cart,
sum(case when ei.event_name = 'Page View' then 1 else 0 end) as total_page_views
from events as e
join event_identifier as ei on e.event_type = ei.event_type 
join page_hierarchy as ph on ph.page_id = e.page_id 
where product_category is not null
group by ph.product_category;

-- 9. What are the top 3 products by purchases?
select ph.page_name, count(visit_id) as no_of_visit
from events as e
join event_identifier as ei on e.event_type = ei.event_type 
join page_hierarchy as ph on ph.page_id = e.page_id 
where ei.event_name = 'Add to Cart'
group by ph.page_name
order by no_of_visit desc
limit 3; 


