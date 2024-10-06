/*This technique is usually used when we inspect an important event and 
want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the 
Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of 
the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:
1. What is the total sales for the 4 weeks before and after 2020-06-15? . 
	What is the growth or reduction rate in actual values and percentage of sales?
2. What about the entire 12 weeks before and after?
3. How do the sale metrics for these 2 periods before and after 
	compare with the previous years in 2018 and 2019?
*/

--1. What is the total sales for the 4 weeks before and after 2020-06-15? . 
-- What is the growth or reduction rate in actual values and percentage of sales?
with sales_4_weeks_before as (
	select sum(sales) as sales_4_weeks_before
	from clean_weekly_sales
	where week_date between (date '2020-06-15' - interval '4 weeks')
	and (date '2020-06-15' - interval '1 week')
),
sales_4_weeks_after as (
	select sum(sales) as sales_4_weeks_after
	from clean_weekly_sales
	where week_date between (date '2020-06-15')
	and (date '2020-06-15' + interval '3 week')
),
combine_2_tables as (
	select sales_4_weeks_before, sales_4_weeks_after
	from sales_4_weeks_before 
	join sales_4_weeks_after on 1 =1 
)
select sales_4_weeks_before, sales_4_weeks_after,
(sales_4_weeks_after - sales_4_weeks_before ) as growth_in_values,
round((sales_4_weeks_after-sales_4_weeks_before)*100.0/sales_4_weeks_before
	,2) as growth_in_percentage
from combine_2_tables;

-- 2. What about the entire 12 weeks before and after?
with sales_12_weeks_before as (
	select sum(sales) as sales_12_weeks_before
	from clean_weekly_sales
	where week_date between (date '2020-06-15' - interval '12 weeks')
	and (date '2020-06-15' - interval '1 week')
),
sales_12_weeks_after as (
	select sum(sales) as sales_12_weeks_after
	from clean_weekly_sales
	where week_date between (date '2020-06-15' )
	and (date '2020-06-15' + interval '11 week')
),
combine_2_tables as (
	select sales_12_weeks_before, sales_12_weeks_after
	from sales_12_weeks_before 
	join sales_12_weeks_after on 1 =1 
)
select sales_12_weeks_before, sales_12_weeks_after,
(sales_12_weeks_after - sales_12_weeks_before ) as growth_in_values,
round((sales_12_weeks_after-sales_12_weeks_before)*100.0/sales_12_weeks_before
	,2) as growth_in_percentage
from combine_2_tables;

-- 3. How do the sale metrics for these 2 periods before and after 
-- compare with the previous years in 2018 and 2019?

------- 4 WEEKS PERIODS -------
with week_number_of_2020_06_15 as (
	select distinct week_number as week_of_2020_06_15
	from clean_weekly_sales
	where week_date = '2020-06-15'
),
four_weeks_before as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15 -4) 
		and (week_of_2020_06_15 -1)
),
four_weeks_after as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15)
		and (week_of_2020_06_15 +3)
),
combine_with_calander_year as (
	select calendar_year, 
	sum(case when week_date in (select * from four_weeks_before) then sales
		end) as sale_4_weeks_before,
	sum(case when week_date in (select * from four_weeks_after) then sales
		end) as sale_4_weeks_after
	from clean_weekly_sales
	group by calendar_year
)
select calendar_year, sale_4_weeks_before, sale_4_weeks_after, 
	(sale_4_weeks_after- sale_4_weeks_before) as growth_in_values,
	round((sale_4_weeks_after- sale_4_weeks_before)*100.0/sale_4_weeks_after,2) as growth_in_percentage
from combine_with_calander_year
order by calendar_year;

------- 12 WEEKS PERIODS -------
with week_number_of_2020_06_15 as (
	select distinct week_number as week_of_2020_06_15
	from clean_weekly_sales
	where week_date = '2020-06-15'
),
twelve_weeks_before as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15 -12) 
		and (week_of_2020_06_15 -1)
),
twelve_weeks_after as (
	select distinct week_date
	from clean_weekly_sales
	join week_number_of_2020_06_15 on 1 =1 
	where week_number between (week_of_2020_06_15)
		and (week_of_2020_06_15 +11)
),
combine_with_calander_year as (
	select calendar_year, 
	sum(case when week_date in (select * from twelve_weeks_before) then sales
		end) as sale_12_weeks_before,
	sum(case when week_date in (select * from twelve_weeks_after) then sales
		end) as sale_12_weeks_after
	from clean_weekly_sales
	group by calendar_year
)
select calendar_year, sale_12_weeks_before, sale_12_weeks_after, 
	(sale_12_weeks_after- sale_12_weeks_before) as growth_in_values,
	round((sale_12_weeks_after- sale_12_weeks_before)*100.0/sale_12_weeks_after,2) as growth_in_percentage
from combine_with_calander_year
order by calendar_year;
