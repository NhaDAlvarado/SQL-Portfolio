-- 1.What are the standard ingredients for each pizza?
with topping_for_meatlovers_pizza as (
	select pr.topping_id, pizza_id, topping_name
	from pizza_recipes as pr
	join pizza_toppings as pt
	on pr.topping_id = pt.topping_id
	where pizza_id =1
),
topping_for_vegetarian_pizza as (
	select pr.topping_id, pizza_id, topping_name
	from pizza_recipes as pr
	join pizza_toppings as pt
	on pr.topping_id = pt.topping_id
	where pizza_id =2
)
select v.topping_name
from topping_for_meatlovers_pizza as m
inner join topping_for_vegetarian_pizza as v
on m.topping_name= v.topping_name;

-- 2.What was the most commonly added extra?
select extras, topping_name, count(topping_name) as count
from new_customer_orders as c
join pizza_toppings as pt
on c.extras = pt.topping_id
group by extras, topping_name
order by count desc
limit 1;

-- 3.What was the most common exclusion?
-- select * from new_customer_orders
select exclusions, topping_name, count(topping_name) as count
from new_customer_orders as c
join pizza_toppings as pt
on c.exclusions = pt.topping_id
group by exclusions, topping_name
order by count desc
limit 1;

-- 4.Generate an order item for each record in the customers_orders table in the format of one of the following:
	-- 	Meat Lovers
	-- 	Meat Lovers - Exclude Beef
	-- 	Meat Lovers - Extra Bacon
	-- 	Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
with replace_topping_id_with_name as (
	select order_id, customer_id,pizza_name, 
	pt_ex.topping_name as exclusion_name,
	pt_extras.topping_name as extras_name
	from new_customer_orders as c
	left join pizza_names as pn
	on pn.pizza_id = c.pizza_id
	left join pizza_toppings as pt_ex
	on pt_ex.topping_id = exclusions
	left join pizza_toppings as pt_extras
	on pt_extras.topping_id = extras
	)
SELECT order_id,
  (CASE
    WHEN exclusion_name IS NULL AND extras_name IS NULL 
		THEN pizza_name
    WHEN exclusion_name IS NOT NULL AND extras_name IS NULL 
		THEN pizza_name || ' - Exclude ' || string_agg(exclusion_name, ', ')
    WHEN exclusion_name IS NULL AND extras_name IS NOT NULL 
		THEN pizza_name || ' - Extra ' || string_agg(extras_name, ', ')
    ELSE pizza_name || ' - Exclude ' || string_agg(exclusion_name, ', ') || ' - Extra ' || string_agg(extras_name, ', ')
  END) AS order_item
FROM replace_topping_id_with_name
GROUP BY order_id, pizza_name, exclusion_name, extras_name;

-- 5.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
with topping_name_for_pizza_name as (
	select pr.pizza_id, pizza_name, topping_name 
	from pizza_toppings as pt
	join pizza_recipes as pr on pt.topping_id = pr.topping_id
	join pizza_names as pn on pr.pizza_id = pn.pizza_id
),
count_no_orders_of_each_pizza as (
	select pizza_id, count(pizza_id) as no_orders_of_each_type_of_pizza
	from runner_orders as r
	join new_customer_orders as c on r.order_id = c.order_id
	where(cancellation is null
   		or cancellation not in ('Restaurant Cancellation', 'Customer Cancellation'))
	group by pizza_id
),
count_repeated_topping as (
	select topping_name, no_orders_of_each_type_of_pizza,
	count(*) over (partition by topping_name) as count_repeated_topping 
	from topping_name_for_pizza_name as t
	join count_no_orders_of_each_pizza as c on t.pizza_id = c.pizza_id 
),
topping_without_repeated as (
	select topping_name, no_orders_of_each_type_of_pizza,
	(no_orders_of_each_type_of_pizza:: text || 'x' || topping_name) as total_order
	from count_repeated_topping
	where count_repeated_topping=1
),
prepare_topping_with_repeated as (
	select topping_name, no_orders_of_each_type_of_pizza,
	lead(no_orders_of_each_type_of_pizza) over (partition by topping_name) as next_value
	from count_repeated_topping
	where count_repeated_topping=2
),
topping_with_repeated as (
	select topping_name, no_orders_of_each_type_of_pizza,
	((no_orders_of_each_type_of_pizza+next_value):: text || 'x' || topping_name) as total_order
	from prepare_topping_with_repeated
	where next_value is not null
)
select topping_name, total_order from topping_without_repeated
union all
select topping_name, total_order from topping_with_repeated
order by total_order desc
