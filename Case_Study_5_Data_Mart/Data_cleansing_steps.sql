/* In a single query, perform the following operations and generate a new table in the data_mart 
schema named clean_weekly_sales:
	- Convert the week_date to a DATE format
	- Add a week_number as the second column for each week_date value, for example any value 
	from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
	- Add a month_number with the calendar month for each week_date value as the 3rd column
	- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
	- Add a new column called age_band after the original segment column using the following 
	mapping on the number inside the segment value
	- Add a new demographic column using the following mapping for the first letter in the segment values:
	- Ensure all null string values with an "unknown" string value in the original segment 
	column as well as the new age_band and demographic columns
	- Generate a new avg_transaction column as the sales value divided by transactions rounded to 
	2 decimal places for each record
*/

-- Generate a new table named clean_weekly_sales
create table clean_weekly_sales as 
select * from weekly_sales;

-- Convert the week_date to a DATE format
alter table clean_weekly_sales
alter column week_date type date
using to_date(week_date, 'DD/MM/YY');

-- Add a week_number as the second column
alter table clean_weekly_sales
add column week_number INT;

update clean_weekly_sales
set week_number = extract(week from week_date);

-- Add a month_number with the calendar month
alter table clean_weekly_sales
add column month_number INT;

update clean_weekly_sales
set month_number = extract(month from week_date);

-- Add a calendar_year column
alter table clean_weekly_sales
add column calendar_year INT;

update clean_weekly_sales
set calendar_year = extract(year from week_date);

-- Add a new column called age_band 
alter table clean_weekly_sales
add column age_band varchar(20); 

update clean_weekly_sales
set age_band = 
	case when right(segment,1) ='1' then 'Young Adults'
		when right(segment,1) ='2' then 'Middle Aged'
		when right(segment,1) in ('3','4') then 'Retirees'
		else 'null'
	end;

-- Add a new demographic column
alter table clean_weekly_sales
add column demographic varchar(20);

update clean_weekly_sales
set demographic = 
	case when left(segment,1) ='C' then 'Couples'
		when left(segment,1) ='F' then 'Families'
		else 'null'
	end;

-- Ensure all null string values with an "unknown" string value
alter table clean_weekly_sales
alter column segment type varchar(10);
	
update clean_weekly_sales
set 
region = replace(region, 'null', 'unknown'),
platform = replace(platform, 'null', 'unknown'),
segment = replace(segment, 'null', 'unknown'),
customer_type = replace(customer_type, 'null', 'unknown'),
age_band = replace(age_band, 'null', 'unknown'),
demographic = replace(demographic, 'null', 'unknown');

-- Generate a new avg_transaction column
alter table clean_weekly_sales
add column avg_transaction numeric;

update clean_weekly_sales
set avg_transaction= round(sales::numeric/transactions::numeric,2) 
