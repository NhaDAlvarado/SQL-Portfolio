-- 1. What is the average salary by job title?
select job_title, round(avg(salary)) as avg_salary
from employee_data 
where salary is not null 
group by job_title
order by avg_salary desc; 

-- 2. What is the distribution of education levels among employees?
select education_level,
	round(100.0*count(education_level)/ (select count(*) from employee_data),2) as percentage
from employee_data
group by education_level;

-- 3. How does salary vary with years of experience?
with categorize_level as (
	select salary, years_of_experience,
		(case 
			when years_of_experience <2 then 'Junior'
			when years_of_experience between 2 and 5 then 'Associate'
			when years_of_experience between 5 and 10 then 'Mid Level'
			else 'Senior'
		end) as experience_level
	from employee_data
)
select experience_level,
	min(salary) || ' - ' || max(salary) as sal_range
from categorize_level
group by experience_level;

-- 4. What is the gender distribution across different job titles?
with gender_count as (
	select job_title,
		sum(case when gender = 'Male' then 1 else 0 end) as male_count,
		sum(case when gender = 'Female' then 1 else 0 end) as female_count
	from employee_data
	group by job_title
),
total_emp_per_title as (
	select job_title, count(*) as total_emp
	from employee_data
	group by job_title
)
select g.job_title, 
	round(100.0* female_count/total_emp) as female_dis,
	round(100.0* male_count/total_emp) as male_dis	
from gender_count as g
join total_emp_per_title as t on g.job_title = t.job_title;

-- 5. Which job titles have the highest and lowest average years of experience?
with avg_yoe as (
	select job_title, round(avg(years_of_experience)) as avg_yoe,
	dense_rank() over (order by avg(years_of_experience) desc) as rank
	from employee_data
	group by job_title
)
select job_title, avg_yoe 
from avg_yoe
where rank = 1 or rank = 108;

-- 6. What is the average salary for each education level?
select education_level, round(avg(salary),2) as avg_salary
from employee_data
group by education_level;

-- 7. How many employees have more than 10 years of experience, and what are their job titles?
select job_title, count(*) as employees_counts
from employee_data
where years_of_experience >10
group by job_title; 

-- 8. What is the total salary expenditure by job title?
select job_title, sum(salary) as expenses
from employee_data
group by job_title;

-- 9. What is the distribution of employees' age across different job titles?
with count_ppl_in_age_groups as (
	select count(*) as num_ppl_in_group,
		case when age <25 then '<25'
				when age >=25 and age < 35 then '25-34'
				when age >=35 and age < 45 then '35-44'
				when age >=45 and age < 55 then '45-54'
				when age >=55 then '55+'
		end as age_groups
	from employee_data
	group by age_groups
),
count_ppl_per_title_in_group as (
	select job_title, count(*) as ppl_per_title_in_group,
	(case when age <25 then '<25'
		when age >=25 and age < 35 then '25-34'
		when age >=35 and age < 45 then '35-44'
		when age >=45 and age < 55 then '45-54'
		when age >=55 then '55+'
	end) as age_groups
	from employee_data
	group by age_groups, job_title
)
select a.age_groups, job_title, 
round(100.0* ppl_per_title_in_group/num_ppl_in_group ,2) as percentage
from count_ppl_per_title_in_group as t 
join count_ppl_in_age_groups as a on t.age_groups = a.age_groups
order by age_groups;

-- 10. Which gender has a higher average salary across different job titles?
with ranking_avg_salary as (
	select job_title, gender, round(avg(salary),2) as avg_salary,
		rank() over (partition by job_title order by avg(salary) desc) as ranking 
	from employee_data
	group by job_title, gender
)
select job_title, gender, avg_salary
from ranking_avg_salary
where ranking =1; 

-- 11. How many employees with a PhD have a salary greater than $100,000?
select education_level, count(*) as num_of_phd
from employee_data
where education_level = 'PhD' and salary > 100000
group by education_level;

-- 12. What is the average number of years of experience for employees with a salary greater than $100,000?
select round(avg(years_of_experience)) as avg_yoe
from employee_data
where salary >100000;

-- 13. How does the average salary differ between males and females across different education levels?
select education_level, gender, round(avg(salary),2) as avg_salary
from employee_data
group by education_level, gender 
order by education_level, gender;

-- 14. What is the most common job title among employees with a Master’s degree?
select job_title, count(*) as num_of_ppl
from employee_data
where education_level = 'Master''s Degree'
group by job_title 
order by num_of_ppl desc;

-- 15. What is the salary range for employees under 30 years old?
select min(salary) as min_salary, max(salary) as max_salary 
from employee_data
where age <30;

-- 16. How many employees have salaries in the top 10% of the dataset?
with percentile_salary as (
    select percentile_cont(0.9) within group (order by salary) as salary_90th
    from employee_data
)
select count(*) as num_of_top_earners
from employee_data, percentile_salary
where salary >= salary_90th;

-- 17. Which job titles have the highest concentration of employees with less than 5 years of experience?
select job_title, count(*) as num_of_ppl 
from employee_data
where years_of_experience <5
group by job_title
order by num_of_ppl desc;

-- 18. What is the salary distribution for employees aged over 40?
select 
	(case when salary <50000 then 'less than 50k'
		when salary between 50000 and 99999 then '50k-100k'
		when salary between 100000 and 149999 then '100k-150k'
		when salary between 150000 and 199999 then '150k-200k'
		else '200k+'
	end) as salary_range,
	count(*) as num_of_employees
from employee_data
where age >40 
group by salary_range
order by num_of_employees;

-- 19. How does the salary compare for employees with the same job title but different education levels?
select job_title, education_level, round(avg(salary),2) as avg_salary, round(avg(years_of_experience),2) as avg_yoe
from employee_data
group by job_title, education_level
order by job_title, avg_salary desc 
