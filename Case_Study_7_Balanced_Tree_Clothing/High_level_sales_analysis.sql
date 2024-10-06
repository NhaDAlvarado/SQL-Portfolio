/*
1. What was the total quantity sold for all products?
2. What is the total generated revenue for all products before discounts?
3. What was the total discount amount for all products?
*/

-- 1. What was the total quantity sold for all products?
select sum(qty) as total_quantity_sold
from sales;

-- 2. What is the total generated revenue for all products before discounts?
select sum(qty*price) as total_revenue_b4_discount
from sales;

-- 3. What was the total discount amount for all products?
select sum(discount) as total_discount
from sales;
