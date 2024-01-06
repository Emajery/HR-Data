Create Database HR;
Use HR;

--Explore the Data

select *
from hr_data

--Clean termdate

Select termdate
from hr_data
order by termdate desc


--Convert termdate date

Update hr_data
set termdate = Format (CONVERT(datetime, Left(termdate,19), 120), 'yyyy-mm-dd')

Select termdate
from hr_data
order by termdate desc

--Convert the date from var() to date

Alter Table hr_data
Add new_termdate Date

update hr_data
set new_termdate = case  when termdate is not Null and isdate(termdate) = 1 Then cast(termdate as datetime) else null End

--Create a new Column call "Age"

Alter Table hr_data
Add age nvarchar(50)

--populate new column with age
update hr_data
set age = datediff (year, birthdate, getdate())

select age
from hr_data

--What's the age distribution in the company?
--age distribution

Select 
 Min(age) as Youngest,
 Max(age) as Oldest
From hr_data

--age group by gender
----first we group distribution
Select age_group,
Count(*) as count 
from
(select 
 case 
      when age <= 21 and age <= 30 then '21 to 30'
      when age <= 31 and age <= 40 then '31 to 40'
	  when age <= 41 and age <= 50 then '41 to 50'
	  else '50+'
 End as age_group
From hr_data
where new_termdate is null
) As Subquery
Group by age_group
Order by age_group

--age distributed by gender

Select age_group, gender,
Count(*) as count 
from
(select 
 case 
      when age <= 21 and age <= 30 then '21 to 30'
      when age <= 31 and age <= 40 then '31 to 40'
	  when age <= 41 and age <= 50 then '41 to 50'
	  else '50+'
 End as age_group, gender
From hr_data
where new_termdate is null
) As Subquery
Group by age_group, gender
Order by age_group, gender

--What's the gender breakdown in the company?
select gender,
count(gender) as count
from hr_data
where new_termdate is null
group by gender
order by gender


--How does gender vary across departments and job titles?
select department,gender,
count(gender) as count
from hr_data
where new_termdate is null
group by department,gender
order by department,gender

--and job titles
select department,jobtitle,gender,
count(gender) as count
from hr_data
where new_termdate is null
group by department,jobtitle,gender
order by department,jobtitle,gender


--What's the race distribution in the company?
select *
from hr_data

select race,
Count(*) as count
from hr_data
where new_termdate is null
group by race
order by count desc


--What's the average length of employment in the company?
select *
from hr_data

select
avg(Datediff(year, hire_date, new_termdate)) as Tenure
from hr_data
where new_termdate is not null and new_termdate <= getdate()


--Which department has the highest turnover rate?
--get total count
select department,
count(*) as total_count
from hr_data
group by department

--get terminated count
select department,
count(case
    when new_termdate is not null and new_termdate <= getdate() then 1 
	end) as terminated_count
from hr_data
group by department

--terminated count/total count
select 
  department,total_count,terminated_count,
   round ((cast (terminated_count as float)/total_count), 3) * 100 as turnover_rate
  from
  (select department,
  count(*) as total_count,
  sum(case
    when new_termdate is not null and new_termdate <= getdate() then 1 
	end) as terminated_count
from hr_data
group by department) as subquery
order by turnover_rate

--What is the tenure distribution for each department?
select
department,
avg(Datediff(year, hire_date, new_termdate)) as Tenure
from hr_data
where new_termdate is not null and new_termdate <= getdate()
group by department
order by Tenure desc

--How many employees work remotely for each department?
select 
   location,
   count(*) as count
from hr_data
where new_termdate is null
group by location

--What's the distribution of employees across different states?
select 
   location_state,
   count(*) as count
from hr_data
where new_termdate is null
group by location_state
order by count desc

--How are job titles distributed in the company?
select 
   jobtitle,
   count(*) as count
from hr_data
where new_termdate is null
group by jobtitle
order by count desc

--How have employee hire counts varied over time?
--Calculate hires
select 
  Year(hire_date) as hire_year,
  count(*) as hires
from hr_data
group by hire_date

--calculate termination
select 
   Year(hire_date) as hire_year,
   count(*) as hires,
   sum(case
    when new_termdate is not null and new_termdate <= getdate() then 1
	end) as terminations
from hr_data
group by Year(hire_date)

--(hire - termination)/hires percent hire change
Select
   hire_year,
   hires,
   terminations,
   hires - terminations as net_change,
   round(((hires - terminations)/cast (hires as float))*100, 0) as percent_hire_change
   from
  (select 
   Year(hire_date) as hire_year,
   count(*) as hires,
   sum(case
    when new_termdate is not null and new_termdate <= getdate() then 1
	end) as terminations
from hr_data
group by Year(hire_date)) as subquery
order by percent_hire_change










