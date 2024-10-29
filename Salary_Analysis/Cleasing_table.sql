DELETE FROM employee_data
WHERE Age IS NULL
   OR Gender IS NULL
   OR Education_Level IS NULL
   OR Job_Title IS NULL
   OR Years_of_Experience IS NULL
   OR Salary IS NULL;

UPDATE employee_data
SET Education_Level = 'Master''s Degree'
WHERE Education_Level = 'Master''s';

UPDATE employee_data
SET Education_Level = 'Bachelor''s Degree'
WHERE Education_Level = 'Bachelor''s';

UPDATE employee_data
SET Education_Level = 'PhD'
WHERE Education_Level = 'phD';


