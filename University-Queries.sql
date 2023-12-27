
use university;

/*For each building, find the number of different students who took at least one course section in that building in the year 2008.
Do not display the building if no students took any courses in that building in 2008. */

select COUNT(DISTINCT takes.ID) as student_number, building 
from takes join section 
		on takes.sec_id = section.sec_id and
		takes.course_id=section.course_id and
		takes.semester = section.semester and
		takes.year = section.year
where takes.year = 2008
group by building
having COUNT(DISTINCT takes.ID) > 0 


/*Find the ID and name of the instructors who also taught course(s) in the department(s) other than
their own departments. Remove the duplicates in the results.
*/

select  distinct name, instructor.ID 
from teaches inner join course
	on teaches.course_id= course.course_id
	join instructor
	on teaches.ID=instructor.ID
where course.dept_name!=instructor.dept_name;


/*Find the departments with the third highest number of instructors. 
Display the department name and the number of instructors of these departments in the result.*/

with inst_num_in_depts as 
	(select distinct top 3 with ties count (distinct instructor.ID) as total_inst_number,dept_name
	from instructor
	group by dept_name
	order by count (distinct instructor.ID) desc)
select instructor.dept_name, count(distinct instructor.ID) as total_instructor_number
from instructor
group by dept_name
having count(distinct instructor.ID) =(select MIN(total_inst_number) from inst_num_in_depts);


/*Find the instructors who earn the highest salary in their own departments. 
Display the name, department name, and salary of these instructors in alphabetical order of the department name.*/

with max_salaries as
	(select max(salary) as highest_salary,dept_name
	from instructor
	group by dept_name)
select name, instructor.dept_name,salary
from instructor inner join max_salaries
	on instructor.dept_name=max_salaries.dept_name and
	instructor.salary=max_salaries.highest_salary
order by dept_name;


/*Find the course(s) taken by the smallest number of students in the year 2007.
The result should display the course title(s) and the number of students that took these course(s) in 2007. 
If a student has taken the same course more than once, this student should be counted only once.*/

with course_with_smallest_num as
	(select top 1 with ties COUNT(distinct ID) as student_number, course_id
	from takes
	where year=2007
	group by course_id
	order by COUNT(distinct ID) asc)
select title, student_number
from course_with_smallest_num inner join course
	on course_with_smallest_num.course_id=course.course_id;


/*Increase the salaries of the instructors who taught at least 2 different courses (different course_id values) by 8% and the salaries of other instructors by 4%. 
Please use begin tran and rollback properly (no need to use commit).*/

go
create view instructors_teaches_many_classes as
	select count(distinct course_id) as course_number, ID
	from teaches
	group by ID
	having count(distinct course_id)>1;
go

begin tran;
	update instructor
	set salary=case
		when ID in (select ID from instructors_teaches_many_classes) then salary*1.08
		else salary*1.04
	end;
rollback;


select*
from instructor


