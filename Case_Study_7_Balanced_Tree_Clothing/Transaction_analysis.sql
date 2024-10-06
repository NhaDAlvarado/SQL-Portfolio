/*
1.How many unique transactions were there?
2. What is the average unique products purchased in each transaction?
3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
4. What is the average discount value per transaction?
5. What is the percentage split of all transactions for members vs non-members?
6. What is the average revenue for member transactions and non-member transactions?
*/

-- 1.How many unique transactions were there?
select count(distinct txn_id) as total_unique_txn
from sales;

-- 2. What is the average unique products purchased in each transaction?
with total_unique_prod as (
	select txn_id, count(distinct prod_id) as total_unique_prod_per_txn
	from sales
	group by txn_id
)
select round(avg(total_unique_prod_per_txn),2) as avg_prod_per_txn
from total_unique_prod;

-- 3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?
with cal_revenue as (
	select txn_id, sum(qty*price*(1-discount/100)) as revenue
	from sales
	group by txn_id
)
select 
percentile_cont(0.25) within group (order by revenue) as percentile_25th,
percentile_cont(0.5) within group (order by revenue) as percentile_50th,
percentile_cont(0.75) within group (order by revenue) as percentile_75th
from cal_revenue;

-- 4. What is the average discount value per transaction?
with total_discount as (
	select txn_id, sum(qty*price* (1-discount/100)) as total_discount 
	from sales
	group by txn_id 
)
select round(avg(total_discount),2) as avg_discount
from total_discount;

-- 5. What is the percentage split of all transactions for members vs non-members?
with transaction_by_mem as (
	select count (txn_id) as txn_by_mem
	from sales
	where member = true
),
transaction_by_non_mem as (
	select count ( txn_id) as txn_by_non_mem
	from sales
	where member = false
)
select txn_by_mem, txn_by_non_mem,
round(100.0*txn_by_mem/(txn_by_mem+txn_by_non_mem),2) as percentage_by_mem,
round(100.0*txn_by_non_mem/(txn_by_mem+txn_by_non_mem),2) as percentage_by_non_mem
from transaction_by_mem
cross join transaction_by_non_mem;

-- 6. What is the average revenue for member transactions and non-member transactions?
with revenue_by_mem as (
	select sum(qty*price*(1-discount/100)) as revenue_by_mem
	from sales
	where member = true
	group by txn_id
),
revenue_by_non_mem as (
	select sum(qty*price*(1-discount/100)) as revenue_by_non_mem
	from sales
	where member = false
	group by txn_id 
)
select round(avg(revenue_by_mem),2), round(avg (revenue_by_non_mem),2)
from revenue_by_mem
cross join revenue_by_non_mem
