# Pull up the employees Employee ID, First Name, Last Name, Age, Gender, Birthdate, Occupation, Salary, Department ID, and Department Name
select sal.employee_id, sal.first_name, sal.last_name, dem.age, dem.gender, dem.birth_date, sal.occupation, sal.salary, dep.department_id, dep.department_name 
from parks_and_recreation.employee_demographics as dem right join parks_and_recreation.employee_salary as sal on dem.employee_id = sal.employee_id 
inner join parks_and_recreation.parks_departments as dep on dep.department_id = sal.dept_id;

# Pull up the employees whose age is 35 and above and salary is equal to or more than 65,000
select first_name, last_name, 'Veteran Man' as Label from parks_and_recreation.employee_demographics where age >= 35 and gender = 'male'
union select first_name, last_name, 'Veteran Woman' as Label from parks_and_recreation.employee_demographics where age >= 35 and gender = 'female'
union select first_name, last_name, 'High Earner' as Label from parks_and_recreation.employee_salary where salary >= 65000;

# Determine the number of digits an employee has in their first and last name and also combine their first and last name into one column.
select first_name, last_name, concat(first_name, ' ', last_name) as Complete_Name, (length(first_name) + length(last_name)) as Number_of_Digits from parks_and_recreation.employee_demographics;

# identify the first and last 4 digits of a employees name.
select first_name, left(first_name, 4), right(first_name, 4 ) from parks_and_recreation.employee_demographics;

# Determine the Birthmonth of each employee
select concat(first_name, ' ', last_name) as Full_Name, substring(birth_date, 6, 2) as Birth_Month from parks_and_recreation.employee_demographics;

# Create a table wherein employees below 40 are considered young and employees above 40 are considered old
select concat(first_name, ' ', last_name) as Full_Name, age, 
case when age <= 40 then 'Young' when age > 40 then 'Old' end from parks_and_recreation.employee_demographics;

# Create a table for Employee Salary Increase and Bonuses wherein 
# employees with a salary of less than 50,000 get a 5% increase
# employees with a salary of greater than 50,000 get a 7% increase
# employees within the Finance and Parks and Recreation Department get a 10% Bonus 
select concat(first_name, ' ', last_name) as Full_Name, salary, dept_id,
case 
when salary < 50000 then salary * 1.05 
when salary > 50000 then salary * 1.07 
end as Salary_increase,
case 
when dept_id = 1 then salary * 1.1 
when dept_id = 6 then salary * 1.1 
end as Bonuses
from parks_and_recreation.employee_salary;

# Create a table of employees whose Department ID is equal to 1
select * from parks_and_recreation.employee_demographics where employee_id in (select employee_id from parks_and_recreation.employee_salary where dept_id = 1);

# Create a table of employees with their names, salary and average salary for all employees
select concat(first_name, ' ', last_name) as Full_Name, salary, (select avg(salary) from parks_and_recreation.employee_salary) from parks_and_recreation.employee_salary;

# Create a table of employees with their names, gender, and average salary per gender.
select concat(dem.first_name, ' ', dem.last_name) as Full_Name, dem.gender, sal.salary, avg(salary) over(partition by gender) as Average_Salary 
from parks_and_recreation.employee_demographics dem join parks_and_recreation.employee_salary sal on dem.employee_id = sal.employee_id;

# Create a table of employees with their names, gender, salary with a row number assigned to each
select concat(dem.first_name, ' ', dem.last_name) as Full_Name, dem.gender, sal.salary, row_number() over(partition by gender order by salary desc) as '#' 
from parks_and_recreation.employee_demographics dem join parks_and_recreation.employee_salary sal on dem.employee_id = sal.employee_id;