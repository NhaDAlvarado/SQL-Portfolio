-- 1.How many pizzas were ordered?
select count(pizza_id) 
from customer_orders;

-- 2.How many unique customer orders were made?
select count(distinct customer_id) 
from customer_orders;

-- 3.How many successful orders were delivered by each runner?
select runner_id, count(order_id) 
from runner_orders
where cancellation is null
   or cancellation not in ('Restaurant Cancellation', 'Customer Cancellation')
group by runner_id
order by runner_id;

-- 4.How many of each type of pizza was delivered?
select pizza_id, count(*)
from customer_orders
group by pizza_id
order by pizza_id;

-- 5.How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id, pizza_name, count(*)
from customer_orders as c
join pizza_names as p 
on c.pizza_id = p.pizza_id
group by customer_id, pizza_name
order by customer_id;

-- 6.What was the maximum number of pizzas delivered in a single order?
select order_id, count(*) as no_of_orders
from customer_orders
group by order_id
order by no_of_orders desc
limit 1;

-- 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
with order_without_cancellation as (
	select customer_id, c.order_id, exclusions, extras, cancellation
	from customer_orders as c
	join runner_orders as r
	on c.order_id = r.order_id
	and (cancellation is null 
		or cancellation not in ('Restaurant Cancellation', 'Customer Cancellation'))
	)
select customer_id, order_id, 
sum(case when (exclusions != 'null' and exclusions is not null and exclusions != '') 
	or (extras != 'null' and extras is not null and extras != '') then 1 else 0 end) as change
from order_without_cancellation
group by customer_id, order_id
order by customer_id;

-- 8.How many pizzas were delivered that had both exclusions and extras?
with order_without_cancellation as (
	select customer_id, c.order_id, exclusions, extras, cancellation
	from customer_orders as c
	join runner_orders as r
	on c.order_id = r.order_id
	and (cancellation is null 
		or cancellation not in ('Restaurant Cancellation', 'Customer Cancellation'))
	)
select customer_id, order_id
from order_without_cancellation
where (exclusions != 'null' and exclusions is not null and exclusions != '') 
	and (extras != 'null' and extras is not null and extras != '')
group by customer_id, order_id;

-- 9.What was the total volume of pizzas ordered for each hour of the day?
select date(order_time) as date, extract (hour from order_time) as hour_of_day, 
count(order_id) as total_no_of_orders
from customer_orders
group by hour_of_day, date
order by date, hour_of_day;

-- 10.What was the volume of orders for each day of the week?
select date(order_time) as date, extract (DOW from order_time) as day_of_week, 
count(order_id) as total_no_of_orders
from customer_orders
group by date, day_of_week
order by date, day_of_week
