/*
1. What are the top 3 products by total revenue before discount?
2. What is the total quantity, revenue and discount for each segment?
3. What is the top selling product for each segment?
4. What is the total quantity, revenue and discount for each category?
5. What is the top selling product for each category?
6. What is the percentage split of revenue by product for each segment?
7. What is the percentage split of revenue by segment for each category?
8. What is the percentage split of total revenue by category?
9. What is the total transaction “penetration” for each product? (hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
10.What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
*/

-- 1. What are the top 3 products by total revenue before discount?
select product_name, sum(qty*s.price) as total_revenue_b4_dis
from sales as s
join product_details as pd on s.prod_id = pd.product_id
group by product_name 
order by total_revenue_b4_dis desc
limit 3;

-- 2. What is the total quantity, revenue and discount for each segment?
select segment_name, sum(qty) as total_qty, 
	sum(qty*s.price) as total_rev_b4_dis,
	round(sum(qty*s.price*discount/100.0),2) as total_dis
from sales as s
join product_details as pd on s.prod_id = pd.product_id
group by segment_name;

-- 3. What is the top selling product for each segment?
with cal_rev_with_dis as (
	select segment_name, product_name, 
	round(sum(qty*s.price*(1-discount/100.0)),2) as total_revenue_with_dis
	from sales as s
	join product_details as pd on s.prod_id = pd.product_id
	group by segment_name, product_name
),
ranking as (
	select segment_name, product_name, total_revenue_with_dis,
	dense_rank() over (partition by segment_name order by total_revenue_with_dis desc) as rk
	from cal_rev_with_dis
)
select segment_name, product_name, total_revenue_with_dis
from ranking
where rk = 1;

-- 4. What is the total quantity, revenue and discount for each category?
select category_name, sum(qty) as total_qty, 
	sum(qty*s.price) as total_rev_b4_dis,
	round(sum(qty*s.price*discount/100.0),2) as total_dis
from sales as s
join product_details as pd on s.prod_id = pd.product_id
group by category_name;

-- 5. What is the top selling product for each category?
with cal_rev_with_dis as (
	select category_name, product_name, 
	round(sum(qty*s.price*(1-discount/100.0)),2) as net_revenue
	from sales as s
	join product_details as pd on s.prod_id = pd.product_id
	group by category_name, product_name
),
ranking as (
	select category_name, product_name, net_revenue,
	dense_rank() over (partition by category_name order by net_revenue desc) as rk
	from cal_rev_with_dis
)
select category_name, product_name, net_revenue
from ranking
where rk = 1;

-- 6. What is the percentage split of revenue by product for each segment?
with rev_per_prod_in_seg as (
	select segment_name, product_name, 
	round(sum(qty*s.price*(1-discount/100.0)),2) as total_rev_per_prod
	from sales as s
	join product_details as pd on s.prod_id = pd.product_id
	group by segment_name, product_name
),
rev_per_seg as (
	select segment_name, 
	round(sum(qty*s.price*(1-discount/100.0)),2) as total_rev_in_seg
	from sales as s
	join product_details as pd on s.prod_id = pd.product_id
	group by segment_name
)
select rs.segment_name, product_name, 
round(100.0*total_rev_per_prod/total_rev_in_seg,2) as percentage_prod_in_seg
from rev_per_prod_in_seg as rs
join rev_per_seg as ps on rs.segment_name = ps.segment_name
order by segment_name, percentage_prod_in_seg desc;

-- 7. What is the percentage split of revenue by segment for each category?
with rev_per_seg_in_cat as (
	select category_name, segment_name, 
	round(sum(qty*s.price*(1-discount/100.0)),2) as total_rev_per_seg
	from sales as s
	join product_details as pd on s.prod_id = pd.product_id
	group by category_name, segment_name
),
rev_per_cat as (
	select category_name, 
	round(sum(qty*s.price*(1-discount/100.0)),2) as total_rev_in_cat
	from sales as s
	join product_details as pd on s.prod_id = pd.product_id
	group by category_name
)
select sc.category_name, segment_name, 
round(100.0*total_rev_per_seg/total_rev_in_cat,2) as percentage_seg_in_cat
from rev_per_seg_in_cat as sc
join rev_per_cat as pc on sc.category_name = pc.category_name
order by category_name, percentage_seg_in_cat desc;

-- 8. What is the percentage split of total revenue by category?
with rev_per_cat as (
	select category_name, 
	round(sum(qty*s.price*(1-discount/100.0)),2) as total_rev_in_cat
	from sales as s
	join product_details as pd on s.prod_id = pd.product_id
	group by category_name
),
total_rev as (
	select round(sum(qty*price*(1-discount/100.0)),2) as total_rev
	from sales 
)
select category_name, 
	round(100.0*total_rev_in_cat/total_rev,2) as percentage_per_cat
from rev_per_cat
cross join total_rev; 

-- 9. What is the total transaction “penetration” for each product? 
--(hint: penetration = number of transactions where at least 1 quantity of a product 
--was purchased divided by total number of transactions)
select prod_id, product_name, 
round (100.0*count(txn_id)/(select count(distinct txn_id) from sales),2) as penetration
from sales as s
join product_details as pd on s.prod_id = pd.product_id
group by prod_id,product_name;

-- 10.What is the most common combination of at least 1 quantity of any 3 products 
-- in a 1 single transaction?
select s.prod_id as prod_a, s1.prod_id as prod_b,s2.prod_id as prod_c,
	count(*) as combination_count
from sales as s
join sales as s1 on s.txn_id = s1.txn_id and s.prod_id <s1.prod_id
join sales as s2 on s2.txn_id = s.txn_id and s1.prod_id<s2.prod_id  
group by prod_a, prod_b, prod_c
order by combination_count desc
limit 1