-- 1.How many unique nodes are there on the Data Bank system?
select count(distinct node_id) 
from customer_nodes;

-- 2.What is the number of nodes per region?
select region_name, count(distinct node_id) as no_of_nodes
from regions as r
join customer_nodes as c on r.region_id = c.region_id
group by region_name;

-- 3.How many customers are allocated to each region?
select region_name, count(distinct customer_id) as no_of_customers
from regions as r
join customer_nodes as c on r.region_id = c.region_id
group by region_name;

-- 4.How many days on average are customers reallocated to a different node?
with days_in_node as (
	select customer_id, node_id,
	sum (end_date - start_date) as days_in_node
	from customer_nodes
	where end_date <> '9999-12-31'
	group by customer_id, node_id
)
select round(avg(days_in_node),2) as avg_days_in_node
from days_in_node;

-- 5.What is the median, 80th and 95th percentile for 
-- this same reallocation days metric for each region?
with days_in_node as (
	select customer_id, node_id,region_id,
	sum (end_date - start_date) as days_in_node
	from customer_nodes
	where end_date <> '9999-12-31'
	group by customer_id, node_id, region_id
)
select region_id,
    round(percentile_cont(0.5) within group (order by days_in_node)::numeric,1) as median_reallocation_days,
    round(percentile_cont(0.8) within group (order by days_in_node)::numeric,1) as p80_reallocation_days,
    round(percentile_cont(0.95) within group (order by days_in_node)::numeric,1) as p95_reallocation_days
from days_in_node
group by region_id 



