# Student Records Management System

A comprehensive relational database management system designed for educational institutions to manage student records, courses, faculty, enrollments, grades, and more.

## 📋 Overview

This database system provides a complete solution for managing all aspects of student administration in an educational institution. It includes 13 interrelated tables with proper constraints, relationships, and data validation to ensure data integrity and consistency.

## 🏗️ Database Schema

### Tables Structure

1. **departments** - Academic departments within the institution
2. **programs** - Degree programs offered by departments
3. **students** - Student information and enrollment details
4. **faculty** - Teaching staff information
5. **courses** - Course offerings and details
6. **enrollments** - Student course registrations
7. **grades** - Academic performance records with automatic letter grade calculation
8. **attendance** - Class attendance tracking
9. **assignments** - Course assignments and assessments
10. **assignment_submissions** - Student assignment submissions
11. **library_books** - Library inventory management
12. **book_loans** - Book borrowing records
13. **financial_transactions** - Student financial records

## 🔗 Relationships

The database implements various relationship types:

- **One-to-Many**: Departments → Programs, Students → Enrollments, Courses → Assignments
- **Many-to-Many**: Students ↔ Courses (through Enrollments), Students ↔ Library Books (through Book Loans)
- **Self-Referencing**: Not applicable in this schema

## ⚙️ Features

- **Automatic Grade Calculation**: Triggers automatically calculate letter grades (A-F) based on numerical scores
- **Data Validation**: Comprehensive constraints including CHECK constraints, ENUM types, and foreign key relationships
- **Audit Trail**: Created_at and updated_at timestamps on all tables
- **Performance Optimization**: Indexes on frequently queried columns
- **Sample Data**: Pre-populated with demonstration data

## 🛠️ Installation

1. Ensure MySQL Server is installed and running
2. Download the `student_records_management_system.sql` file
3. Execute the script using one of these methods:

**Method 1: MySQL Command Line**
```bash
mysql -u your_username -p < student_management.sql
```

**Method 2: MySQL Workbench**
- Open MySQL Workbench
- Connect to your server
- File → Open SQL Script → select `student_management.sql`
- Execute the script

## 📊 Sample Queries

Here are some example queries you can run after installation:

### 1. List all students with their programs
```sql
SELECT s.student_number, s.first_name, s.last_name, p.program_name, d.department_name
FROM students s
JOIN programs p ON s.program_id = p.program_id
JOIN departments d ON p.department_id = d.department_id;
```

### 2. Show courses with assigned faculty
```sql
SELECT c.course_code, c.course_name, f.first_name, f.last_name, d.department_name
FROM courses c
JOIN faculty f ON c.faculty_id = f.faculty_id
JOIN departments d ON c.department_id = d.department_id;
```

### 3. View student grades with automatic letter grades
```sql
SELECT s.first_name, s.last_name, c.course_code, c.course_name, g.grade, g.letter_grade
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN courses c ON g.course_id = c.course_id;
```

### 4. Check course enrollment counts
```sql
SELECT c.course_code, c.course_name, COUNT(e.student_id) as enrolled_students
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id;
```

## 🔒 Constraints Implemented

- **Primary Keys**: All tables have auto-increment primary keys
- **Foreign Keys**: Proper relational integrity with ON DELETE CASCADE/SET NULL
- **Unique Constraints**: Prevent duplicate records (e.g., student numbers, course codes)
- **Check Constraints**: Validate data ranges (e.g., grades between 0-100)
- **NOT NULL**: Essential fields are required
- **ENUM Types**: Restricted value sets for status fields

## 📈 Performance Features

- Indexes on all foreign key columns
- Indexes on frequently searched columns (status, program_id, etc.)
- Composite indexes for common query patterns

## 🗂️ Data Management

The system includes mechanisms for:
- Adding new students, courses, and faculty
- Recording grades with automatic letter grade calculation
- Tracking attendance and assignments
- Managing library resources
- Processing financial transactions

## 🔄 Maintenance

Regular maintenance tasks:
- Monitor database performance
- Backup regularly using MySQL dump utilities
- Review and optimize queries as needed
- Update the schema as institutional requirements change

## 📝 Customization

This database can be extended by:
- Adding new tables for specific institutional needs
- Creating additional views for reporting
- Implementing stored procedures for complex operations
- Adding triggers for additional automation

## 🆘 Support

For questions or issues:
1. Review the schema documentation above
2. Check MySQL error logs for specific issues
3. Verify your MySQL version compatibility (designed for MySQL 5.6+)

## 📄 License

This database schema is provided as an assignment but also a template for educational institutions. Modify as needed for your specific requirements.

---

*This Student Records Management System provides a solid foundation for managing educational institution data with proper relational database design principles.*
