--CLEAN UP TABLES customer_orders
-- replace 'null' value to null
update customer_orders
set exclusions = NULL 
where exclusions = 'null';

update customer_orders
set extras = NULL 
where extras = 'null';

-- Split the comma-separated exclusions, extras into rows
CREATE TABLE new_customer_orders AS
SELECT order_id, customer_id, pizza_id,
	unnest(string_to_array(exclusions, ',')::int[]) AS exclusions,
	unnest(string_to_array(extras, ',')::int[]) AS extras,
	order_time
FROM customer_orders;

--CLEAN UP TABLE topping_recipes	
-- Created temp table and split the comma-separated topping_id into rows
CREATE TEMP TABLE temp_pizza_recipes AS
SELECT pizza_id, unnest(string_to_array(topping_id, ',')::int[]) AS topping_id
FROM pizza_recipes;

-- rename column
alter table pizza_recipes
rename column toppings TO topping_id;

-- insert value from temp table to pizza_recipes table
INSERT INTO pizza_recipes (pizza_id, topping_id)
SELECT pizza_id, topping_id
FROM temp_pizza_recipes;

-- delete unwanted rows
DELETE FROM pizza_recipes
WHERE topping_id= '1, 2, 3, 4, 5, 6, 8, 10' 
or topping_id = '4, 6, 7, 9, 11, 12';