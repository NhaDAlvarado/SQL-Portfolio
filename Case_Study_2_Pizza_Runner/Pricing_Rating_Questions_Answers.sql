-- 1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
-- how much money has Pizza Runner made so far if there are no delivery fees?
with count_no_orders_of_each_pizza as (
	select pizza_id, count(pizza_id) as no_orders_of_each_type_of_pizza
	from runner_orders as r
	join new_customer_orders as c on r.order_id = c.order_id
	where(cancellation is null
   		or cancellation not in ('Restaurant Cancellation', 'Customer Cancellation'))
	group by pizza_id
),
money_make_on_meat_lovers as (
	select pizza_id,
	sum (case 
		when pizza_id = 1 then 12*no_orders_of_each_type_of_pizza else 0 end) as money_make_on_meat_lovers
	from count_no_orders_of_each_pizza
	where pizza_id =1
	group by pizza_id
),
money_make_on_vegeterian as (
	select pizza_id,
	sum (case 
		when pizza_id = 2 then 10*no_orders_of_each_type_of_pizza else 0 end) as money_make_on_vegetarian
	from count_no_orders_of_each_pizza
	where pizza_id =2
	group by pizza_id
),
combine_2_type_pizza as (
	select money_make_on_meat_lovers, money_make_on_vegetarian
	from money_make_on_meat_lovers
	join money_make_on_vegeterian
	on 1=1
)
select (money_make_on_meat_lovers+ money_make_on_vegetarian) as total_money_make
from combine_2_type_pizza;

-- 2.What if there was an additional $1 charge for any pizza extras?
	-- 	Add cheese is $1 extra
with count_no_orders_of_each_pizza as (
	select pizza_id, count(extras) as no_of_extras, count(pizza_id) as no_orders_of_each_type_of_pizza
	from runner_orders as r
	join new_customer_orders as c on r.order_id = c.order_id
	where(cancellation is null
   		or cancellation not in ('Restaurant Cancellation', 'Customer Cancellation'))
	group by pizza_id
),
money_make_on_meat_lovers as (
	select no_of_extras,
	sum (case 
		when pizza_id = 1 then 12*no_orders_of_each_type_of_pizza+no_of_extras else 0 end) as money_make_on_meat_lovers
	from count_no_orders_of_each_pizza
	where pizza_id =1
	group by no_of_extras
),
money_make_on_vegeterian as (
	select no_of_extras,
	sum (case 
		when pizza_id = 2 then 10*no_orders_of_each_type_of_pizza+no_of_extras else 0 end) as money_make_on_vegetarian
	from count_no_orders_of_each_pizza
	where pizza_id =2
	group by no_of_extras
),
combine_2_type_pizza as (
	select money_make_on_meat_lovers, money_make_on_vegetarian
	from money_make_on_meat_lovers
	join money_make_on_vegeterian
	on 1=1
)
select (money_make_on_meat_lovers+ money_make_on_vegetarian) as total_money_make_with_charge_on_extras
from combine_2_type_pizza;
-- 3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
-- how would you design an additional table for this new dataset 
-- generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
ALTER TABLE runner_orders
ADD CONSTRAINT order_runner_unique UNIQUE (order_id, runner_id);

CREATE TABLE runner_ratings (
    rating_id SERIAL PRIMARY KEY,
    order_id INTEGER,
    runner_id INTEGER,
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    rating_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id, runner_id) REFERENCES runner_orders(order_id, runner_id)  -- Composite foreign key
);

INSERT INTO runner_ratings (order_id, runner_id, rating)
VALUES 
  (1, 1, 5),  
  (2, 1, 4),  
  (3, 1, 3),  
  (4, 2, 5),  
  (5, 3, 4),  
  (6, 3, null),  
  (7, 2, 5),  
  (8, 2, 3),  
  (9, 2, null),  
  (10, 1, 5); 

-- 4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
	-- 	customer_id
	-- 	order_id
	-- 	runner_id
	-- 	rating
	-- 	order_time
	-- 	pickup_time
	-- 	Time between order and pickup
	-- 	Delivery duration
	-- 	Average speed
	-- 	Total number of pizzas
with clean_and_join_tables as (
	select customer_id, r.order_id, r.runner_id,rating, 
	(case when distance like '%km' then left(distance, -2)
	else distance end) as delivery_distance, 
	left(duration,2) as duration,
	order_time, pickup_time
	from new_customer_orders as c
	join runner_orders as r on r.order_id = c.order_id
	join runner_ratings as rr on rr.order_id = r.order_id
	where(cancellation is null
   		or cancellation not in ('Restaurant Cancellation', 'Customer Cancellation'))
	)
select customer_id, order_id, runner_id,rating,
	ceil(extract (epoch from (pickup_time::TIMESTAMP -order_time))/60) as time_bwt_order_pickup_in_minutes,
	delivery_distance, duration,
	round((delivery_distance::numeric/(duration::numeric/60)),2)as "speed(km/h)",
	order_time, pickup_time
from clean_and_join_tables;
-- 5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras 
--and each runner is paid $0.30 per kilometre traveled 
-- how much money does Pizza Runner have left over after these deliveries?
WITH count_no_orders_of_each_pizza AS (
    SELECT pizza_id, 
           (CASE 
                WHEN distance LIKE '%km' THEN LEFT(distance, -2) 
                ELSE distance 
            END) AS delivery_distance, 
           COUNT(pizza_id) AS no_orders_of_each_type_of_pizza
    FROM runner_orders AS r
    JOIN new_customer_orders AS c ON r.order_id = c.order_id
    WHERE (cancellation IS NULL 
           OR cancellation NOT IN ('Restaurant Cancellation', 'Customer Cancellation'))
    GROUP BY pizza_id, (CASE WHEN distance LIKE '%km' THEN LEFT(distance, -2) ELSE distance END)
),
money_make_on_meat_lovers AS (
    SELECT pizza_id, delivery_distance,
           SUM(CASE 
                WHEN pizza_id = 1 THEN (12 * no_orders_of_each_type_of_pizza - (0.3 * delivery_distance::NUMERIC)) 
                ELSE 0 
           END) AS money_make_on_meat_lovers
    FROM count_no_orders_of_each_pizza
    WHERE pizza_id = 1
    GROUP BY pizza_id, delivery_distance
),
money_make_on_vegetarian AS (
    SELECT pizza_id, delivery_distance,
           SUM(CASE 
                WHEN pizza_id = 2 THEN (10 * no_orders_of_each_type_of_pizza - (0.3 * delivery_distance::NUMERIC)) 
                ELSE 0 
           END) AS money_make_on_vegetarian
    FROM count_no_orders_of_each_pizza
    WHERE pizza_id = 2
    GROUP BY pizza_id, delivery_distance
),
combine_2_type_pizza AS (
    SELECT COALESCE(m_meat.money_make_on_meat_lovers, 0) AS money_make_on_meat_lovers,
           COALESCE(m_veg.money_make_on_vegetarian, 0) AS money_make_on_vegetarian
    FROM money_make_on_meat_lovers AS m_meat
    FULL OUTER JOIN money_make_on_vegetarian AS m_veg ON m_meat.pizza_id = m_veg.pizza_id
)
SELECT sum(money_make_on_meat_lovers + money_make_on_vegetarian) AS total_money_make
FROM combine_2_type_pizza;
