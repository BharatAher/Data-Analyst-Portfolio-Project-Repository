/*
Employee Data Exploration 
Skills used: Joins, Windows Functions, Aggregate Functions, Creating Views, stored procedures, cursors, creating indexes, triggers, SQL sub-queries

*/

--What is the query to retrieve all the columns from the "employee" table?
select * from employee;

--What is the query to retrieve only the "e_name", "e_salary", and "e_gender" columns from the "employee" table?
select e_name, e_salary, e_gender from employee;

--What is the query to retrieve all the distinct "e_dept" values from the "employee" table?
select distinct e_dept from employee;

--What is the query to retrieve the "e_name", "e_gender", and "e_dept" columns for all female employees from the "employee" table?
select e_name, e_gender, e_dept from employee where e_gender='Female';

--What is the query to retrieve all columns for employees under the age of 30 from the "employee" table?
select * from employee where e_age<30;

--What is the query to retrieve all columns for employees with a salary greater than 100000 from the "employee" table?
select * from employee where e_salary>100000;

--What is the query to retrieve all columns for employees with a salary greater than 100000 and under the age of 30 from the "employee" table?
select * from employee where e_salary>100000 and e_age<30;

--What is the query to retrieve all columns for male employees under the age of 30 from the "employee" table?
select * from employee where e_gender='Male' and e_age<30;

--What is the query to retrieve all columns for employees who are not female from the "employee" table?
select * from employee where not e_gender='Female';

--What is the query to retrieve all columns for employees whose name contains the letter "J" from the "employee" table?
select * from employee where e_name LIKE '%J%';

--What is the query to retrieve all columns for employees between the ages of 25 and 35 from the "employee" table?
select * from employee where e_age between 25 and 35;

--What is the query to retrieve the maximum salary from the "employee" table?
select MIN(e_salary) from employee;

--What is the query to retrieve the maximum age from the "employee" table?
select MAX(e_salary) from employee;

--What is the query to retrieve the number of female employees from the "employee" table?
select count(*) from employee where e_gender='Female';

--What is the query to retrieve all columns for employees sorted by salary in ascending order from the "employee" table?
select * from employee order by e_salary;

--What is the query to retrieve all columns for employees sorted by salary in descending order from the "employee" table?
select * from employee order by e_salary DESC;

--What is the query to retrieve the top 3 employees sorted by salary in descending order from the "employee" table?
select top 3 * from employee order by e_salary DESC;

-- ## To find the second top salary person from the employee table, you can use the following SQL query###
SELECT TOP 1 e_name, e_salary 
FROM employee 
WHERE e_salary < (
   SELECT MAX(e_salary) FROM employee 
)
ORDER BY e_salary DESC;

--What is the average salary of male and female employees in the company?
select avg(e_salary),e_gender from employee group by e_gender;

--What is the average age of employees in each department?
select avg(e_age), e_dept from employee group by e_dept;

--What is the average age of employees in each department in descending order?
select avg(e_age), e_dept from employee group by e_dept order by avg(e_age) desc;

--What is the average salary of employees in each department, only considering departments where the average salary is greater than $100,000?
select e_dept, avg(e_salary) as avg_salary
from employee
group by e_dept
having avg(e_salary)>100000;

--What is the average salary of employees in each department, only considering departments where the average salary is greater than $100,000, in descending order of department name?
select e_dept, avg(e_salary) as avg_salary
from employee
group by e_dept
having avg(e_salary)>100000
order by e_dept DESC;

--These are SQL queries that involve joining two tables - "employee" and "department".
--The first query uses an inner join to return only the rows that have matching values in both tables.
select employee.e_name, employee.e_dept, department.d_name, department.d_location
From employee
Inner Join department 
on employee.e_dept=department.d_name;

--The second query uses a left join to return all rows from the left table (employee) and the matching rows from the right table (department).
select employee.e_name, employee.e_dept, department.d_name, department.d_location
From employee
left Join department 
on employee.e_dept=department.d_name;

--The third query uses a right join to return all rows from the right table (department) and the matching rows from the left table (employee). 
select employee.e_name, employee.e_dept, department.d_name, department.d_location
From employee
right Join department 
on employee.e_dept=department.d_name;

--The fourth query uses a full outer join to return all rows from both tables. If there are no matching rows in either table, it returns NULL values for the non-matching columns.
select employee.e_name, employee.e_dept, department.d_name, department.d_location
From employee
full Join department 
on employee.e_dept=department.d_name;

--The fifth query uses a cross join to return all possible combinations of rows between the two tables.
SELECT employee.e_name, employee.e_dept, department.d_name, department.d_location
FROM employee
CROSS JOIN department;


--This query performs a union of the two tables, which combines the distinct rows of both tables into a single result set, omitting duplicates.
select * from student_d1
union
select * from student_d2

--This query performs a union of the two tables, including all rows from both tables, even if they are duplicates.
select * from student_d1
union all
select * from student_d2

--This query performs a set difference operation on the two tables.
select * from student_d1
except
select * from student_d2

--This query performs a set intersection operation on the two tables.
select * from student_d1
intersect
select * from student_d2

-- a view is a virtual table that is based on the result set of a SELECT statement

-- Suppose we want to create a view that shows the department name and the total salary paid to all employees in that department. 
--We can create the view using the following SQL statement

CREATE VIEW e_salary AS
SELECT d.d_name, SUM(e.e_salary) as total_salary
FROM department d
INNER JOIN employee e
ON d.d_id = e.e_id
GROUP BY d.d_name;

--Check the output for e_salary view
select * from e_salary

--The "MERGE" statement allows you to insert, update, or delete data in a target table based on the data from a source table. 
MERGE INTO employee_target AS tgt
USING employee_Source AS src
ON tgt.e_id = src.e_id
WHEN MATCHED THEN
    UPDATE SET tgt.e_name = src.e_name, tgt.e_dept = src.e_dept
WHEN NOT MATCHED THEN
    INSERT (e_id, e_name, e_dept)
    VALUES (src.e_id, src.e_name, src.e_dept);

-- Examples of calling the target table
select * from employee_source;
select * from employee_target;


--The procedure "employee_gender" accepts a parameter "@gender" of type varchar(20) and selects all the rows from the "employee" table where the value in the "e_gender" column matches the provided parameter value.
create procedure employee_gender @gender varchar(20) 
as
select * from employee
where e_gender=@gender
go

-- Examples of calling the procedure with different parameter values
exec employee_gender @gender='Male'

exec employee_gender @gender='Female'

--Trigger
CREATE TRIGGER tr_employee_audit
ON employee
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    IF @@ROWCOUNT = 0
        RETURN;

    DECLARE @operation varchar(10);
    IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)
        SET @operation = 'UPDATE';
    ELSE IF EXISTS(SELECT * FROM inserted)
        SET @operation = 'INSERT';
    ELSE IF EXISTS(SELECT * FROM deleted)
        SET @operation = 'DELETE';

    INSERT INTO employee_audit (operation, e_id, e_name, e_dept)
    SELECT @operation, e_id, e_name, e_dept
    FROM inserted i
    UNION ALL
    SELECT @operation, e_id, e_name, e_dept
    FROM deleted d;
END;

-- Examples of calling the trigger
select * from employee_audit;


-- Stored Procedures:

CREATE PROCEDURE GetEmployeesByDepartment
@deptName varchar(100)
AS
BEGIN
SELECT e_name, e_salary, e_age, e_gender, e_dept
FROM employee e
JOIN department d ON e.e_dept = d.d_name
WHERE d_name = @deptName
END

-- Examples of calling the procedure
EXEC GetEmployeesByDepartment 'Analytics'


-- Functions
CREATE FUNCTION GetAvgSalaryByDepartment
(@deptName varchar(100))
RETURNS int
AS
BEGIN
DECLARE @avgSalary int
SELECT @avgSalary = AVG(e_salary)
FROM employee e
JOIN department d ON e.e_dept = d.d_name
WHERE d_name = @deptName
RETURN @avgSalary
END

-- Examples of calling the Function
SELECT dbo.GetAvgSalaryByDepartment('Analytics')


-- Cursors:

DECLARE @name varchar(100)
DECLARE @salary int
DECLARE employee_cursor CURSOR FOR
SELECT e_name, e_salary
FROM employee
OPEN employee_cursor
FETCH NEXT FROM employee_cursor INTO @name, @salary
WHILE @@FETCH_STATUS = 0
BEGIN
PRINT 'Name: ' + @name + ' Salary: ' + CAST(@salary AS varchar(10))
FETCH NEXT FROM employee_cursor INTO @name, @salary
END
CLOSE employee_cursor
DEALLOCATE employee_cursor

-- Examples of calling the cursor
EXEC employee_cursor;

--Sub-queries
SELECT e_name, e_salary, e_dept
FROM employee
WHERE e_salary > (
    SELECT AVG(e_salary)
    FROM employee
    WHERE e_dept = 'Analytics'
) AND e_dept = 'Sales';

