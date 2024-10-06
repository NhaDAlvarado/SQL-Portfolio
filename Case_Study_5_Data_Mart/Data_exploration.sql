/*
1. What day of the week is used for each week_date value?
2. What range of week numbers are missing from the dataset?
3. How many total transactions were there for each year in the dataset?
4. What is the total sales for each region for each month?
5. What is the total count of transactions for each platform
6. What is the percentage of sales for Retail vs Shopify for each month?
7. What is the percentage of sales by demographic for each year in the dataset?
8. Which age_band and demographic values contribute the most to Retail sales?
9. Can we use the avg_transaction column to find the average transaction size 
	for each year for Retail vs Shopify? If not - how would you calculate it 
	instead?
*/

-- 1. What day of the week is used for each week_date value?
select extract(dow from week_date) as day_of_week 
from clean_weekly_sales;

-- 2. What range of week numbers are missing from the dataset?
select * from generate_series(1,53) as missing_week_numbers
where missing_week_numbers not in (
	select distinct week_number from clean_weekly_sales
)
order by missing_week_numbers;

-- 3. How many total transactions were there for each year in the dataset?
select calendar_year, sum(transactions) as total_txn_per_year
from clean_weekly_sales
group by calendar_year;

-- 4. What is the total sales for each region for each month?
select region, sum(sales) as total_sale_per_region
from clean_weekly_sales
group by region;

-- 5. What is the total count of transactions for each platform
select platform, sum(transactions) as total_txn_per_platform
from clean_weekly_sales
group by platform;

-- 6. What is the percentage of sales for Retail vs Shopify for each month?
with sale_per_platform_per_month as (
	select platform,month_number, sum(sales) as total_sale_per_platform_per_month
	from clean_weekly_sales
	group by platform, month_number
	order by month_number, platform
),
separate_retail_sale as (
	select platform,month_number, total_sale_per_platform_per_month,
	lag(total_sale_per_platform_per_month) 
		over (partition by month_number order by platform, month_number) as retail_sale
	from sale_per_platform_per_month
)
select month_number, 
round(retail_sale*100.0/(total_sale_per_platform_per_month+retail_sale),2) as retail_sale_percentage,
round(total_sale_per_platform_per_month*100.0/(total_sale_per_platform_per_month+retail_sale),2) as shopify_sale_percentage
from separate_retail_sale
where retail_sale is not null;

-- 7. What is the percentage of sales by demographic for each year in the dataset?
select calendar_year, 
round(100.0*sum (
	case when demographic = 'Couples' then sales end)/sum(sales)
	,2) as couples_sale_percentage,
round(100.0*sum (
	case when demographic = 'Families' then sales end)/sum(sales)
	,2) as families_sale_percentage,
round(100.0*sum (
	case when demographic = 'unknown' then sales end)/sum(sales)
	,2) as unknow_sale_percentage
from clean_weekly_sales
group by calendar_year
order by calendar_year;

-- 8. Which age_band and demographic values contribute the most to Retail sales?
select age_band, demographic, sum(sales) as total_sales
from clean_weekly_sales
where platform = 'Retail'
group by age_band, demographic
order by total_sales desc;

-- 9. Can we use the avg_transaction column to find the average transaction size 
-- 	for each year for Retail vs Shopify? If not - how would you calculate it 
-- 	instead?
select calendar_year, platform, 
	round(avg(avg_transaction),2) as use_avg_tranctions,
	round(sum(sales)::numeric/sum(transactions)::numeric,2) as use_sum_sales_over_sum_transactions
from clean_weekly_sales
group by calendar_year, platform

/*Calculating an average of averages will not yield the proper answer. 
The correct way is to add all transactions and divide by the total 
number of transactions.
*/



