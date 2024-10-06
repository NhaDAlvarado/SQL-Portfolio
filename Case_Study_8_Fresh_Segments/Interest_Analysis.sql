/*
1. Which interests have been present in all month_year dates in our dataset?
2. Using this same total_months measure - calculate the cumulative percentage 
of all records starting at 14 months - which total_months value passes the 90% 
cumulative percentage value?
3. If we were to remove all interest_id values which are lower than the 
total_months value we found in the previous question - how many total data 
points would we be removing?
4. Does this decision make sense to remove these data points from a business 
perspective? Use an example where there are all 14 months present to a removed 
interest example for your arguments - think about what it means to have less months 
present from a segment perspective.
5. After removing these interests - how many unique interests are there for 
each month?
*/

--1. Which interests have been present in all month_year dates in our dataset?
with interest_id_present_count as (
	select interest_id, count (month_year) as total_months_present,
	(select count (distinct month_year) as count_all_month_year from interest_metrics)
	from interest_metrics
	group by interest_id 
)
select interest_id
from interest_id_present_count
where total_months_present= count_all_month_year
order by interest_id;

-- 2. Using this same total_months measure - calculate the cumulative percentage 
-- of all records starting at 14 months - which total_months value passes the 90% 
-- cumulative percentage value?
with month_count as (
	select interest_id, count(_month) as total_months
	from interest_metrics 
	group by interest_id
),
interest_id_count as (
	select total_months, count(interest_id) as count_interest
	from month_count
	group by total_months
),
cumulative_percentage as (
	select total_months, count_interest,
	round(
		100.0*sum(count_interest) over (order by total_months desc)
		/(select count(id) from interest_map)
		,2 )as cumulative_percentage
	from interest_id_count
)
select total_months, count_interest, cumulative_percentage
from cumulative_percentage
where cumulative_percentage > 90;

-- 3. If we were to remove all interest_id values which are lower than the 
-- total_months value we found in the previous question - how many total data 
-- points would we be removing?
with data_points_need_to_be_removed as (
	select interest_id, count(_month) as total_months
	from interest_metrics 
	group by interest_id
	having count(_month) <6
)
select count(interest_id) as total_data_points_removed
from interest_metrics
where interest_id in (select interest_id from data_points_need_to_be_removed );

-- 4. Does this decision make sense to remove these data points from a business 
-- perspective? Use an example where there are all 14 months present to a removed 
-- interest example for your arguments - think about what it means to have less months 
-- present from a segment perspective.
with data_points_need_to_be_removed as (
	select interest_id, count(_month) as total_months
	from interest_metrics 
	group by interest_id
	having count(_month) <6
),
interest_id_present as (
	select me. month_year, count(interest_id) as total_interest_present
	from interest_metrics as me
	group by me.month_year 
),
interest_id_got_removed as (
	select month_year, count(interest_id) as data_points_removed
	from interest_metrics
	where interest_id in (select interest_id from data_points_need_to_be_removed )
	group by month_year 
)
select p.month_year,total_interest_present, data_points_removed,
	round(100.0*data_points_removed/total_interest_present,2)as percentage_removed
from interest_id_present as p
join interest_id_got_removed as r on p.month_year = r.month_year 
order by month_year; 
/* Since percentage_removed is so small for every month, removing any interest_id 
values below the total_months value is absolutely acceptable.
*/
	
-- 5. After removing these interests - how many unique interests are there for 
-- each month?
with data_points_need_to_be_removed as (
	select interest_id, count(_month) as total_months
	from interest_metrics 
	group by interest_id
	having count(_month) <6
),
interest_id_present as (
	select me. month_year, count(interest_id) as total_interest_present
	from interest_metrics as me
	group by me.month_year 
),
interest_id_got_removed as (
	select month_year, count(interest_id) as data_points_removed
	from interest_metrics
	where interest_id in (select interest_id from data_points_need_to_be_removed )
	group by month_year 
)
select p.month_year,total_interest_present, data_points_removed,
	(total_interest_present -data_points_removed) as total_interest_left_after_removed
from interest_id_present as p
join interest_id_got_removed as r on p.month_year = r.month_year 
order by month_year;