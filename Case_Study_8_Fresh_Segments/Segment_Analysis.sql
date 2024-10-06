/*
1. Using our filtered dataset by removing the interests with less than 6 months 
worth of data, which are the top 10 and bottom 10 interests which have the largest 
composition values in any month_year? Only use the maximum composition value for each 
interest but you must keep the corresponding month_year
2. Which 5 interests had the lowest average ranking value?
3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
4. For the 5 interests found in the previous question - what was minimum and maximum 
percentile_ranking values for each interest and its corresponding year_month value? 
Can you describe what is happening for these 5 interests?
5. How would you describe our customers in this segment based off their composition 
and ranking values? What sort of products or services should we show to these customers 
and what should we avoid?
*/

-- create table clean_interest_metrics
-- CREATE TABLE clean_interest_metrics AS
-- SELECT *
-- FROM interest_metrics
-- WHERE interest_id NOT IN (
--     SELECT interest_id
--     FROM (
--         SELECT interest_id, COUNT(_month) AS total_months
--         FROM interest_metrics
--         GROUP BY interest_id
--         HAVING COUNT(_month) < 6
--     ) AS data_points_need_to_be_removed
-- );

--1. Using our filtered dataset by removing the interests with less than 6 months 
-- worth of data, which are the top 10 and bottom 10 interests which have the largest 
-- composition values in any month_year? Only use the maximum composition value for each 
-- interest but you must keep the corresponding month_year

with bottom_10 as (
	select month_year, interest_id, max(composition) as max_composition 
	from clean_interest_metrics
	group by month_year, interest_id 
	order by max_composition 
	limit 10 
),
top_10 as (
	select month_year, interest_id, max(composition) as max_composition 
	from clean_interest_metrics
	group by month_year,interest_id 
	order by max_composition desc
	limit 10 
)
select month_year, interest_id, max_composition  from bottom_10
union all
select month_year, interest_id, max_composition  from top_10;

-- 2. Which 5 interests had the lowest average ranking value?
select interest_id, round(avg(ranking)) as avg_rank 
from clean_interest_metrics
group by interest_id 
order by avg_rank asc
limit 5;

--3. Which 5 interests had the largest standard deviation in their percentile_ranking value?
select interest_id, round(stddev(percentile_ranking)::numeric,2) as stddev_ranking 
from clean_interest_metrics
group by interest_id 
order by stddev_ranking desc
limit 5;

-- 4. For the 5 interests found in the previous question - what was minimum and maximum 
-- percentile_ranking values for each interest and its corresponding year_month value? 
-- Can you describe what is happening for these 5 interests?
with top_5_largest_stddev as (
	select interest_id, round(stddev(percentile_ranking)::numeric,2) as stddev_ranking 
	from clean_interest_metrics
	group by interest_id 
	order by stddev_ranking desc
	limit 5
),
min_percentage_rank as (
	select c.interest_id
	, min(percentile_ranking) as min_percentile
	from clean_interest_metrics as c
	right join top_5_largest_stddev as t on c.interest_id = t.interest_id 
	group by c.interest_id
),
max_percentage_rank as (
	select c.interest_id
	,max(percentile_ranking) as max_percentile
	from clean_interest_metrics as c
	right join top_5_largest_stddev as t on c.interest_id = t.interest_id 
	group by c.interest_id
),
min_month_year as (
	select month_year as min_mth_year, m.interest_id, min_percentile
	from min_percentage_rank as m
	left join clean_interest_metrics as c 
		on m.interest_id = c.interest_id and min_percentile = percentile_ranking
),
max_month_year as (
	select month_year as max_mth_year, m.interest_id, max_percentile
	from max_percentage_rank as m
	left join clean_interest_metrics as c 
		on m.interest_id = c.interest_id and max_percentile = percentile_ranking
)
select mi.interest_id, min_mth_year, min_percentile, max_mth_year, max_percentile
from min_month_year as mi
join max_month_year as ma on mi.interest_id = ma.interest_id; 