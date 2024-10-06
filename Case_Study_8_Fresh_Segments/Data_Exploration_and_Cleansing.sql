/*
1.Update the interest_metrics table by modifying the month_year column 
to be a date data type with the start of the month
2. What is count of records in the interest_metrics for each month_year 
value sorted in chronological order (earliest to latest) with the null values 
appearing first?
3. What do you think we should do with these null values in the interest_metrics
4. How many interest_id values exist in the interest_metrics table but not in 
the interest_map table? What about the other way around?
5. Summarise the id values in the interest_map by its total record 
count in this table
6. What sort of table join should we perform for our analysis and why? 
Check your logic by checking the rows where interest_id = 21246 in your joined 
output and include all columns from interest_metrics and all columns from 
interest_map except from the id column.
7. Are there any records in your joined table where the month_year value is before 
the created_at value from the interest_map table? Do you think these values are 
valid and why?
*/

-- 1.Update the interest_metrics table by modifying the month_year column 
--to be a date data type with the start of the month

--Temporarily change month_year column type to TEXT
ALTER TABLE interest_metrics
ALTER COLUMN month_year TYPE TEXT;

-- Convert month_year values to a DATE format
UPDATE interest_metrics
SET month_year = TO_DATE(month_year || '-01', 'YYYY-MM-DD');

ALTER TABLE interest_metrics
ALTER COLUMN month_year TYPE date
USING month_year::date

-- 2. What is count of records in the interest_metrics for each month_year 
-- value sorted in chronological order (earliest to latest) with the null values 
-- appearing first?
select month_year, count(*) as records_count 
from interest_metrics 
group by month_year
order by month_year is null desc, month_year asc; 

-- 3. What do you think we should do with these null values in the interest_metrics
delete from interest_metrics 
where month_year is null
returning *;

--4. How many interest_id values exist in the interest_metrics table but not in 
--the interest_map table? What about the other way around?

ALTER TABLE interest_metrics
ALTER COLUMN interest_id TYPE INTEGER
USING interest_id::INTEGER;

select count(distinct interest_id) as id_not_in_map
from interest_metrics as me 
left join interest_map as ma on me.interest_id = ma.id 
where ma.id is null; 

select count(distinct id) as id_not_in_metrics
from interest_metrics as me 
right join interest_map as ma on me.interest_id = ma.id 
where me.interest_id is null; 

--5. Summarise the id values in the interest_map by its total record 
--count in this table
select id, interest_name, count(*) as record_per_id
from interest_metrics as me 
right join interest_map as ma on me.interest_id = ma.id 
group by id, interest_name;

-- 6. What sort of table join should we perform for our analysis and why? 
-- Check your logic by checking the rows where interest_id = 21246 in your joined 
-- output and include all columns from interest_metrics and all columns from 
-- interest_map except from the id column.
select _month, _year, interest_id, composition, index_value, ranking, percentile_ranking,
month_year, interest_name, interest_summary, created_at, last_modified
from interest_metrics me join interest_map m
on me.interest_id = m.id
where interest_id = 21246;

-- 7. Are there any records in your joined table where the month_year value is before 
-- the created_at value from the interest_map table? Do you think these values are 
-- valid and why?
select _month, _year, interest_id, composition, index_value, ranking, percentile_ranking,
month_year,created_at, interest_name, interest_summary, last_modified
from interest_metrics me join interest_map m
on me.interest_id = m.id
where month_year < created_at; 
/* yes these records are valid because both the dates have the same month and we set 
the date for the month_year column to be the first day of the month
*/

