-- 1.How many customers has Foodie-Fi ever had?
select count (distinct customer_id) 
from subscriptions;

-- 2.What is the monthly distribution of trial plan start_date values for our dataset 
-- use the start of the month as the group by value
select count(distinct start_date)
from subscriptions
where plan_id = 0;

-- 3.What plan start_date values occur after the year 2020 for our dataset? 
--Show the breakdown by count of events for each plan_name
select plan_id,count(start_date)
from subscriptions
where extract(year from start_date) > 2020
group by plan_id;

-- 4.What is the customer count and percentage of customers 
-- who have churned rounded to 1 decimal place?
with count_total_customers as (
	select count(distinct customer_id) as total_customer
	from subscriptions
),
total_churn as (
	select count(distinct customer_id) as total_churn
	from subscriptions
	where plan_id = 4
)
select total_churn, 
	round(total_churn*100::numeric/total_customer,1) as percentage
from count_total_customers
join total_churn
on 1=1;

-- 5.How many customers have churned straight after their initial free trial 
-- what percentage is this rounded to the nearest whole number?
with cus_with_plan0_and_plan4 as (
	select customer_id, plan_id, start_date,
	count(*) over(partition by customer_id ) as count_no_cus
	from subscriptions
	where plan_id =4 or plan_id = 0
),
upcoming_date as (
	select customer_id, plan_id, start_date,
		lead(start_date) over(partition by customer_id order by start_date) as upcoming_date
	from cus_with_plan0_and_plan4
	where count_no_cus = 2 
), 
total_churn_right_after_trial as (
	select count(customer_id) as churn_right_after_trial
	from upcoming_date
	where date(upcoming_date) - date(start_date) = 7 
	and upcoming_date is not null
),
count_total_customers as (
	select count(distinct customer_id) as total_customer
	from subscriptions
)
select churn_right_after_trial, 
	round(churn_right_after_trial*100::numeric/total_customer,1) as percentage
from total_churn_right_after_trial
join count_total_customers
on 1=1;

-- 6.What is the number and percentage of customer plans 
-- after their initial free trial?
with rank_plans_per_cus as (
	select plan_id, customer_id, start_date,
	rank() over (partition by customer_id order by start_date) as rank
	from subscriptions
	where plan_id != 0 
	)
select plan_id, count(customer_id) as total_cus,
	round(count(customer_id)::numeric*100/1000,1) as percentage
from rank_plans_per_cus
where rank =1
group by plan_id;

-- 7.What is the customer count and percentage breakdown 
-- of all 5 plan_name values at 2020-12-31?
with finding_the_latest_plan as (
	select customer_id, plan_id, start_date,
	rank() over (partition by customer_id order by start_date desc) as rank
	from subscriptions
	where date(start_date) <='2020-12-31'
)
select plan_id, count(customer_id) as total_cus,
	round(count(customer_id)::numeric*100/1000,1) as percentage
from finding_the_latest_plan
where rank =1
group by plan_id;

-- 8.How many customers have upgraded to an annual plan in 2020?
with finding_the_latest_plan as (
	select customer_id, start_date,
	rank() over (partition by customer_id order by start_date desc) as rank
	from subscriptions
	where plan_id =3 and date(start_date) <='2020-12-31'
)
select count(customer_id) as total_customer
from finding_the_latest_plan
where rank =1;

-- 9.How many days on average does it take for a customer to an annual plan 
-- from the day they join Foodie-Fi?
with finding_the_latest_plan as (
	select customer_id, start_date,
	count(*) over (partition by customer_id) as count_cus_per_plan
	from subscriptions
	where plan_id in (0,3)
),
find_date_to_anual_plan as (
	select customer_id, start_date,
	lead(start_date) over (partition by customer_id) as annual_plan_jon_date
	from finding_the_latest_plan
	where count_cus_per_plan =2
)
select 
round(avg(date(annual_plan_jon_date) - date(start_date)),2) as avg_days_take_to_join_annual_plan
from find_date_to_anual_plan
where annual_plan_jon_date is not null;

-- 10.Can you further breakdown this average value 
-- into 30 day periods (i.e. 0-30 days, 31-60 days etc)
with finding_the_latest_plan as (
	select customer_id, start_date,
	count(*) over (partition by customer_id) as count_cus_per_plan
	from subscriptions
	where plan_id in (0,3)
),
find_date_to_anual_plan as (
	select customer_id, start_date,
	lead(start_date) over (partition by customer_id) as annual_plan_jon_date
	from finding_the_latest_plan
	where count_cus_per_plan =2
),
days_join_annual_plan as (
	select customer_id, 
	date(annual_plan_jon_date) - date(start_date)as days_take_to_join_annual_plan
	from find_date_to_anual_plan
	where annual_plan_jon_date is not null
)
select count(customer_id),
(case
	when days_take_to_join_annual_plan <= 30 then '0-30 days'
	when days_take_to_join_annual_plan <= 60 then '31-60 days'
	when days_take_to_join_annual_plan <= 90 then '61-90 days'
	when days_take_to_join_annual_plan <= 120 then '91-120 days'
	when days_take_to_join_annual_plan <= 150 then '151-180 days'
	when days_take_to_join_annual_plan <= 180 then '181-210 days'
	else 'more than 211 days'
end )as "days_breakdown"
from days_join_annual_plan
group by "days_breakdown";

-- 11.How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
with finding_the_latest_plan as (
	select customer_id,plan_id, start_date,
	count(*) over (partition by customer_id) as count_cus_per_plan
	from subscriptions
	where plan_id in (1,2)
), 
find_the_latest_plan as (
	select customer_id,plan_id, start_date,
		rank() over (partition by customer_id order by start_date desc) as latest_plan
	from finding_the_latest_plan
	where count_cus_per_plan = 2
)
select count(customer_id) as no_of_cus_downgraded
from find_the_latest_plan
where latest_plan = 1 and plan_id =1 
