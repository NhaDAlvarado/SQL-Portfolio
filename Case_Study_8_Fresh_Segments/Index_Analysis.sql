/*
The index_value is a measure which can be used to reverse calculate the average 
composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the composition column by the 
index_value column rounded to 2 decimal places.

1. What is the top 10 interests by the average composition for each month?
2. For all of these top 10 interests - which interest appears the most often?
3. What is the average of the average composition for the top 10 interests for 
each month?
4. What is the 3 month rolling average of the max average composition value 
from September 2018 to August 2019 and include the previous top ranking interests 
in the same output shown below.
5. Provide a possible reason why the max average composition might change from month 
to month? Could it signal something is not quite right with the overall business 
model for Fresh Segments?
*/

-- 1. What is the top 10 interests by the average composition for each month?
with cal_avg_comp as (
	select month_year, interest_id,
	round(composition::numeric/index_value::numeric,2) as average_comp
	from clean_interest_metrics
),
ranking_avg_comp as (
	select month_year, interest_id, average_comp,
	dense_rank() over (partition by month_year order by average_comp desc) as rank
	from cal_avg_comp
)
select month_year, interest_id, average_comp
from ranking_avg_comp
where rank<=10;

-- 2. For all of these top 10 interests - which interest appears the most often?
with cal_avg_comp as (
	select month_year, interest_id,
	round(composition::numeric/index_value::numeric,2) as average_comp
	from clean_interest_metrics
),
ranking_avg_comp as (
	select month_year, interest_id, average_comp,
	dense_rank() over (partition by month_year order by average_comp desc) as rank
	from cal_avg_comp
),
top_10 as (
	select month_year, interest_id, average_comp
	from ranking_avg_comp
	where rank<=10
)
select interest_id, count(*) as appeared_times
from top_10
group by interest_id
order by appeared_times desc;

--3. What is the average of the average composition for the top 10 interests for 
-- each month?
with cal_avg_comp as (
	select month_year, interest_id,
	round(composition::numeric/index_value::numeric,2) as average_comp
	from clean_interest_metrics
),
ranking_avg_comp as (
	select month_year, interest_id, average_comp,
	dense_rank() over (partition by month_year order by average_comp desc) as rank
	from cal_avg_comp
),
top_10 as (
	select month_year, interest_id, average_comp
	from ranking_avg_comp
	where rank<=10
)
select month_year, round(avg(average_comp),2) as avg_of_avg_comp
from top_10
group by month_year
order by month_year;

--  4. What is the 3 month rolling average of the max average composition value 
-- from September 2018 to August 2019 and include the previous top ranking interests 
-- in the same output shown below.
with find_max_comp as (
	select month_year, interest_name,
		round(composition::numeric/index_value::numeric,2) as max_index_composition,
	dense_rank() over (partition by month_year 
		order by round(composition::numeric/index_value::numeric,2) desc) as ranking
	from interest_metrics 
	left join interest_map on id = interest_id 
),
three_months_avg as (
	select month_year, interest_name, max_index_composition,
	round (avg(max_index_composition) over (order by month_year
		rows between 2 preceding and current row ),2) as three_months_moving_avg,
		lag(interest_name) over() || ': ' || lag(max_index_composition) over() as one_month_ago,
		lag(interest_name,2) over () || ': ' || lag(max_index_composition,2) over() as two_months_ago 
	from find_max_comp
	where ranking =1
)	
select month_year, interest_name, max_index_composition, 
	three_months_moving_avg, one_month_ago, two_months_ago 
from three_months_avg
where two_months_ago is not null;

-- 5. Provide a possible reason why the max average composition might change from month 
-- to month? Could it signal something is not quite right with the overall business 
-- model for Fresh Segments?
