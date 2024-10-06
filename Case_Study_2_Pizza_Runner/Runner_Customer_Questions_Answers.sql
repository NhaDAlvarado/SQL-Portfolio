-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT
    to_char(registration_date, 'w') AS week_start,
    COUNT(runner_id) AS runners_signed_up
FROM runners
WHERE registration_date >= '2021-01-01'
GROUP BY week_start
ORDER BY week_start;

-- 2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select  runner_id,
ceil(avg(extract (epoch from (pickup_time::TIMESTAMP -order_time))/60)) as avg_time
from runner_orders as r
join customer_orders as c
on r.order_id = c.order_id 
where pickup_time != 'null'
group by runner_id;

-- 3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
select  r.order_id, count(r.order_id) as no_of_pizza_per_order,
ceil(avg(extract (epoch from (pickup_time::TIMESTAMP -order_time))/60)) as avg_time
from runner_orders as r
join customer_orders as c
on r.order_id = c.order_id 
where pickup_time != 'null'
group by r.order_id
order by no_of_pizza_per_order;

-- 4.What was the average distance travelled for each customer?
with fix_mix_match_type_in_distance as (
	select runner_id, 
	(case when distance like '%km' then left(distance, -2)
	else distance end) as distance
	from runner_orders
	where distance != 'null'
)
select runner_id, 
round(avg(distance::numeric),2) as avg_distance
from fix_mix_match_type_in_distance
group by runner_id
order by runner_id;

-- 5.What was the difference between the longest and shortest delivery times for all orders?
with fix_mix_match_type_in_duration as (
	select runner_id, 
	left(duration,2) as duration
	from runner_orders
	where duration != 'null'
)
select max(duration::numeric) as longest_time_taken,
min(duration::numeric) as shortest_time_take
from fix_mix_match_type_in_duration;

-- 6.What was the average speed for each runner for each delivery 
-- and do you notice any trend for these values?
with fix_mix_match_type as (
	select runner_id, order_id,
	(case when distance like '%km' then left(distance, -2)
	else distance end) as distance,
	left(duration,2) as duration
	from runner_orders
	where duration != 'null'
)
select runner_id, order_id,
round((distance::numeric/(duration::numeric/60)),2)as "speed(km/h)"
from fix_mix_match_type
order by runner_id;

-- 7.What is the successful delivery percentage for each runner?
with count_success_fail_orders as (
	select runner_id, count(*)as total_order,
	sum(case when cancellation in ('Restaurant Cancellation', 'Customer Cancellation') then 1 else 0
	end) as fail_deliveries
	from runner_orders
	group by runner_id
	)
select runner_id, 
	round((total_order-fail_deliveries)*100::numeric/total_order::numeric,2) as percentage_successful_orders
from count_success_fail_orders
order by runner_id;