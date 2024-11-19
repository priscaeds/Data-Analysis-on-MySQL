-- 1. IMPORT A TABLE INTO THE WORKBENCH AND CARRY OUT THE FOLLOWING:

use project;
select * from employee_data;


-- A. SHOW DISTINCT VALUES ON ANY FIELD ON THE TABLE.
select distinct Emp_ID as ids from employee_data;
select Count(distinct State) as states from employee_data;
select count(distinct Dept_ID) as unique_ids from employee_data;

-- B. CREATE A FUNCTION ON THE TABLE
-- this function will calculate and return the highest salary of employees within a specified department.

-- first lets convert the salary column from text to decimal
alter table employee_data change column Salary Salary decimal(10,2);

DELIMITER //
create function 
Highestpaidemployeebydept(input_dept_id int)
returns decimal(10, 2)
deterministic
begin
  declare highest_salary decimal(10, 2);
  select ifnull(max(replace(Salary,',','')),0.00) into highest_salary
  from employee_data
  where dept_id = input_dept_id;
  return highest_salary;
end//
DELIMITER ;

-- usage
select Highestpaidemployeebydept(10);

-- C. CREATE INSERT, DELETE AND UPDATE TRIGGERS ON THE TABLE

-- Lets create a new table for the trigger actions
create table employee_audit(
     id int auto_increment primary key,
	 emp_id int,
     action varchar(50),
	 timestamp DATETIME,
     old_data text,
     new_data text
);    
Select * from employee_audit;

 -- INSERT Trigger
DELIMITER //
create trigger tr_insert after insert on employee_data 
for each row
begin
    insert into employee_audit (emp_id, action, timestamp)
    values (new.emp_id, 'inserted', now());
end//
DELIMITER ;    

-- testing the trigger
insert into employee_data values (1000, 'John', 'Obi',600.00, 40, 'M', 'Enu','2022-01-04',null);
insert into employee_data values (1079, 'Ada', 'Goerge',100.00, 10, 'F', 'Ben','04/05/2023',null);

-- DELETE Trigger
DELIMITER //
Create trigger tr_delete After delete on employee_data
for each row 
begin
   insert into employee_audit(emp_id, action, timestamp)
   values (old.emp_id, 'Deleted', now());
end//
DELIMITER ;

-- testing the trigger
delete from employee_data where Emp_ID = 1000; 

-- UPDATE Trigger
DELIMITER //
create trigger tr_update after update on employee_data
for each row
begin
    insert into employee_audit (emp_id, action, timestamp, old_data, new_data)
    values (old.emp_id, 'Updated', now(), concat('old: ', old.First_Name,'', old.Last_Name), 
concat('new: ', new.First_Name,'', new.Last_Name));
end//
DELIMITER ;

-- Testing the update trigger 
update employee_data set Last_Name = 'Eze' where Emp_ID = 1079 and Salary = 100;
update employee_data set Salary = 350.00 where Emp_ID = 1057;
select * from employee_audit;


-- D. CREATE STORED PROCEDURES

DELIMITER //
Create procedure large_salary()
begin
    select * from employee_data where Salary >= 300;
END //
DELIMITER ;  

-- usage
Call large_salary();  


-- E. ADD A NEW FIELD TO THE TABLE
Alter table employee_data add column Role varchar(50);
select * from employee_data;

-- F. CHANGE THE NAME OF A FIELD ON YOUR TABLE
Alter table employee_data rename column Role to Job_Title;
select * from employee_data;

-- G. CREATE A NEW USER IN THE DATABASE
Create user 'Mike'@'%' identified by '3557';

-- H. GRANT THE USER SELECT, INSERT AND ALTER PRIVILEGES
Grant select, insert, alter on employee_data.* to 'Mike'@'%';

-- I. REVOKE THE PRIVILEGES GRANTED TO THE NEW USER
Revoke select, insert, alter on employee_data.*  from 'Mike'@'%';


-- 2. A. WHAT IS THE DIFFERENCE BETWEEN CHAR AND VARCHAR DATATYPES?

-- The common difference betwen them is that a char datatype is suitable for data with fixed lengths eg zip codes, phone numbers etc 
-- while a varchar type is suitable for data with varying lengths i.e names, location and so on.


-- B. WHAT IS THE DIFFERENCE BETWEEN SQL AND MYSQL?

-- Sql also called structured query language is a language for managing (storing, manipulating and retrieving) data in the 
-- database while mysql is a database management system where data is stored and managed.


-- C. WHY ARE TRIGGERS CREATED IN A DATABASE
-- Triggers are created because they ensure consistency by enforcing business rules and constraints,
-- They can log changes thereby providing a trail for auditing and tracking purposes
-- They also restrict or allow access to sensitive data based on user roles or permissions,
-- Triggers also validate data as it is inserted, deleted or updated, thus preventing incorrect data entry.


-- D. WHAT IS THE DIFFERENCE BETWEEN A PRIMARY AND A FOREIGN KEY?
-- A primary key uniquely identifies each record in a table and it cannot be null while a foreign key references
-- the primary key of another table and it can be null.alter


-- E. CREATE AN ERD WITH 6 RELATED TABLES

-- The tables Employee, Task, Department, Invoice, Client and Project tables were created and their relationships are read as follows:
-- A department has many employees (one to many),
-- An employee can work on many tasks(one to many),
-- Many tasks are part of one project(many to one),
-- A project has many tasks (one to many),
-- One project has many invoices (one to many)
-- A client can have many invoices (one to many),
-- Many invoices belong to one client(many to one).


