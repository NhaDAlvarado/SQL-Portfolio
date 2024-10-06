/*Using a single SQL query - create a new output table which has the following details:

How many times was each product viewed?
How many times was each product added to cart?
How many times was each product added to a cart but not purchased (abandoned)?
How many times was each product purchased?
Additionally, create another table which further aggregates the data for the 
above points but this time for each product category instead of individual products.

Use your 2 new output tables - answer the following questions:

1. Which product had the most views, cart adds and purchases?
2. Which product was most likely to be abandoned?
3. Which product had the highest view to purchase percentage?
4. What is the average conversion rate from view to cart add?
5. What is the average conversion rate from cart add to purchase?
*/

-- CREATE A NEW OUPUT TABLE NAME PRODUCT_TAB BY PRODUCT NAME

create table product_tab (
page_name varchar(50),
page_views_count int,
add_cart_count int,
abandoned_count int,
purchase_count int
);

with page_view_and_add_cart_count as (
	select ph.page_name,
	sum(case when event_name = 'Page View' then 1 else 0 end) as page_views_count,
	sum(case when event_name = 'Add to Cart' then 1 else 0 end) as add_cart_count	
	from events as e
	join event_identifier as ei on e.event_type = ei.event_type 
	join page_hierarchy as ph on ph.page_id = e.page_id 
	group by ph.page_name
),

created_purchase_id as (
	select distinct visit_id as purchase_id, ph.page_name, ei.event_name
	from events as e
	join event_identifier as ei on e.event_type = ei.event_type 
	join page_hierarchy as ph on ph.page_id = e.page_id 
	where event_name = 'Purchase'
),

abandoned_count as (
	select ph.page_name, count(distinct visit_id) as abandoned_count 
-- purchase_id, visit_id, ei.event_name
	from events as e
	left join created_purchase_id on purchase_id = visit_id 
	join page_hierarchy as ph on ph.page_id = e.page_id 
	join event_identifier as ei on e.event_type = ei.event_type 
	where purchase_id is null and ei.event_name = 'Add to Cart'
	group by ph.page_name
),
purchase_count as (
	select ph.page_name, count(distinct visit_id) as purchase_count
	from events as e
	left join created_purchase_id on purchase_id = visit_id 
	join page_hierarchy as ph on ph.page_id = e.page_id 
	join event_identifier as ei on e.event_type = ei.event_type 
	where purchase_id is not null and ei.event_name = 'Add to Cart'
	group by ph.page_name
),
combine_all_tabs as (
	select p.page_name, page_views_count, add_cart_count, abandoned_count, purchase_count
	from page_view_and_add_cart_count as p
	join abandoned_count as a on p.page_name = a.page_name
	join purchase_count as pa on p.page_name = pa.page_name
)
	
insert into product_tab (page_name, page_views_count, add_cart_count, abandoned_count, purchase_count)
select page_name, page_views_count, add_cart_count, abandoned_count, purchase_count
from combine_all_tabs;

-- CREATE A NEW OUPUT TABLE NAME CATEGORY_TAB BY CATEGORY NAME

create table product_category_tab (
product_category varchar(50),
page_views_count int,
add_cart_count int,
abandoned_count int,
purchase_count int
);

with page_view_and_add_cart_count as (
	select ph.product_category,
	sum(case when event_name = 'Page View' then 1 else 0 end) as page_views_count,
	sum(case when event_name = 'Add to Cart' then 1 else 0 end) as add_cart_count	
	from events as e
	join event_identifier as ei on e.event_type = ei.event_type 
	join page_hierarchy as ph on ph.page_id = e.page_id 
	group by ph.product_category
),

created_purchase_id as (
	select distinct visit_id as purchase_id, ph.product_category, ei.event_name
	from events as e
	join event_identifier as ei on e.event_type = ei.event_type 
	join page_hierarchy as ph on ph.page_id = e.page_id 
	where event_name = 'Purchase'
),

abandoned_count as (
	select ph.product_category, count(distinct visit_id) as abandoned_count 
-- purchase_id, visit_id, ei.event_name
	from events as e
	left join created_purchase_id on purchase_id = visit_id 
	join page_hierarchy as ph on ph.page_id = e.page_id 
	join event_identifier as ei on e.event_type = ei.event_type 
	where purchase_id is null and ei.event_name = 'Add to Cart'
	group by ph.product_category
),
purchase_count as (
	select ph.product_category, count(distinct visit_id) as purchase_count
	from events as e
	left join created_purchase_id on purchase_id = visit_id 
	join page_hierarchy as ph on ph.page_id = e.page_id 
	join event_identifier as ei on e.event_type = ei.event_type 
	where purchase_id is not null and ei.event_name = 'Add to Cart'
	group by ph.product_category
),
combine_all_tabs as (
	select p.product_category, page_views_count, add_cart_count, abandoned_count, purchase_count
	from page_view_and_add_cart_count as p
	join abandoned_count as a on p.product_category = a.product_category
	join purchase_count as pa on p.product_category = pa.product_category
)
	
insert into product_category_tab (product_category, page_views_count, add_cart_count, abandoned_count, purchase_count)
select product_category, page_views_count, add_cart_count, abandoned_count, purchase_count
from combine_all_tabs;

-- 1. Which product had the most views, cart adds and purchases?
select page_name, page_views_count as most_views 
from product_tab
order by page_views_count desc
limit 1;

select page_name, add_cart_count as most_add_cart
from product_tab
order by add_cart_count desc
limit 1;

select page_name, purchase_count as most_purchase
from product_tab
order by purchase_count desc
limit 1;

-- 2. Which product was most likely to be abandoned?
select page_name, abandoned_count as most_abandoned
from product_tab
order by abandoned_count desc
limit 1;

-- 3. Which product had the highest view to purchase percentage?
select page_name, 
round(100.0*purchase_count/page_views_count,2) as view_to_purchase_percentage
from product_tab
order by view_to_purchase_percentage desc
limit 1;

-- 4. What is the average conversion rate from view to cart add?
select 
round(avg(100.0*add_cart_count/page_views_count),2) as avg_view_to_add_cart_percentage
from product_tab;

-- 5. What is the average conversion rate from cart add to purchase?
select 
round(avg(100.0*purchase_count/add_cart_count),2) as avg_add_cart_to_purchase_percentage
from product_tab
