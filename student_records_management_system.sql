-- Create the database.
CREATE DATABASE student_records_management_system;
USE student_records_management_system;

-- 1. Departments Table (One-to-Many with Programs, Courses, and Faculty).
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_code VARCHAR(10) UNIQUE NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    building VARCHAR(50),
    phone VARCHAR(15),
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 2. Programs Table (Many-to-One with Departments, One-to-Many with Students).
CREATE TABLE programs (
    program_id INT AUTO_INCREMENT PRIMARY KEY,
    program_code VARCHAR(10) UNIQUE NOT NULL,
    program_name VARCHAR(100) NOT NULL,
    duration_years INT NOT NULL CHECK (duration_years BETWEEN 1 AND 6),
    total_credits INT NOT NULL,
    department_id INT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE
);

-- 3. Students Table (Many-to-One with Programs, One-to-Many with Enrollments, Grades).
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    program_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    graduation_date DATE,
    status ENUM('Active', 'Inactive', 'Graduated', 'Suspended') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (program_id) REFERENCES programs(program_id) ON DELETE CASCADE,
    CHECK (graduation_date IS NULL OR graduation_date > enrollment_date)
);

-- 4. Faculty Table (Many-to-One with Departments, One-to-Many with Courses).
CREATE TABLE faculty (
    faculty_id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_number VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    office_room VARCHAR(20),
    department_id INT NOT NULL,
    title ENUM('Professor', 'Associate Professor', 'Assistant Professor', 'Lecturer') NOT NULL,
    hire_date DATE NOT NULL,
    status ENUM('Active', 'On Leave', 'Retired') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE
);

-- 5. Courses Table (Many-to-One with Departments, Programs; One-to-Many with Enrollments, Grades).
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(10) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    credits INT NOT NULL CHECK (credits BETWEEN 1 AND 6),
    department_id INT NOT NULL,
    program_id INT NOT NULL,
    faculty_id INT,
    description TEXT,
    prerequisites TEXT,
    semester ENUM('Fall', 'Spring', 'Summer') NOT NULL,
    academic_year YEAR NOT NULL,
    max_capacity INT DEFAULT 30,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE CASCADE,
    FOREIGN KEY (program_id) REFERENCES programs(program_id) ON DELETE CASCADE,
    FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id) ON DELETE SET NULL
);

-- 6. Enrollments Table (Many-to-Many between Students and Courses).
CREATE TABLE enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    enrollment_status ENUM('Enrolled', 'Dropped', 'Completed') DEFAULT 'Enrolled',
    drop_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (student_id, course_id, academic_year),
    CHECK (drop_date IS NULL OR drop_date >= enrollment_date)
);

-- 7. Grades Table (Many-to-One with Students and Courses).
CREATE TABLE grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    faculty_id INT NOT NULL,
    grade DECIMAL(4,2) CHECK (grade BETWEEN 0 AND 100),
    letter_grade CHAR(1),
    grade_date DATE NOT NULL,
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id) ON DELETE CASCADE,
    UNIQUE KEY unique_grade (student_id, course_id)
);

-- 8. Attendance Table (Many-to-One with Students and Courses).
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('Present', 'Absent', 'Late', 'Excused') NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    UNIQUE KEY unique_attendance (student_id, course_id, attendance_date)
);

-- 9. Assignments Table (Many-to-One with Courses).
CREATE TABLE assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    faculty_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    due_date DATE NOT NULL,
    max_score INT NOT NULL CHECK (max_score > 0),
    weight DECIMAL(5,2) CHECK (weight BETWEEN 0 AND 100),
    assignment_type ENUM('Homework', 'Quiz', 'Project', 'Exam', 'Lab') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    FOREIGN KEY (faculty_id) REFERENCES faculty(faculty_id) ON DELETE CASCADE
);

-- 10. Assignment Submissions Table (Many-to-One with Students and Assignments).
CREATE TABLE assignment_submissions (
    submission_id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT NOT NULL,
    student_id INT NOT NULL,
    submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    score DECIMAL(5,2) CHECK (score >= 0),
    feedback TEXT,
    file_path VARCHAR(255),
    status ENUM('Submitted', 'Graded', 'Late', 'Missing') DEFAULT 'Submitted',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (assignment_id) REFERENCES assignments(assignment_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    UNIQUE KEY unique_submission (assignment_id, student_id)
);

-- 11. Library Books Table.
CREATE TABLE library_books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    publisher VARCHAR(100),
    publication_year YEAR,
    category VARCHAR(50),
    total_copies INT DEFAULT 1 CHECK (total_copies >= 0),
    available_copies INT DEFAULT 1 CHECK (available_copies >= 0 AND available_copies <= total_copies),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 12. Book Loans Table (Many-to-Many between Students and Library Books).
CREATE TABLE book_loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    student_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('Active', 'Returned', 'Overdue') DEFAULT 'Active',
    fine_amount DECIMAL(10,2) DEFAULT 0.00 CHECK (fine_amount >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES library_books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    CHECK (due_date > loan_date),
    CHECK (return_date IS NULL OR return_date >= loan_date)
);

-- 13. Financial Transactions Table (One-to-Many with Students).
CREATE TABLE financial_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    transaction_type ENUM('Tuition', 'Fee', 'Payment', 'Refund') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    transaction_date DATE NOT NULL,
    due_date DATE,
    status ENUM('Pending', 'Paid', 'Overdue') DEFAULT 'Pending',
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Bank Transfer') DEFAULT 'Cash',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

-- Create a function to calculate letter grade.
DELIMITER //
CREATE FUNCTION calculate_letter_grade(grade DECIMAL(4,2)) 
RETURNS CHAR(1)
DETERMINISTIC
BEGIN
    RETURN CASE 
        WHEN grade >= 90 THEN 'A'
        WHEN grade >= 80 THEN 'B'
        WHEN grade >= 70 THEN 'C'
        WHEN grade >= 60 THEN 'D'
        ELSE 'F'
    END;
END //
DELIMITER ;

-- Create trigger to automatically set letter_grade when grade is inserted or updated.
DELIMITER //
CREATE TRIGGER set_letter_grade_insert
BEFORE INSERT ON grades
FOR EACH ROW
BEGIN
    SET NEW.letter_grade = calculate_letter_grade(NEW.grade);
END //

CREATE TRIGGER set_letter_grade_update
BEFORE UPDATE ON grades
FOR EACH ROW
BEGIN
    SET NEW.letter_grade = calculate_letter_grade(NEW.grade);
END //
DELIMITER ;

-- Create indexes for better performance.
CREATE INDEX idx_students_program ON students(program_id);
CREATE INDEX idx_students_status ON students(status);
CREATE INDEX idx_courses_department ON courses(department_id);
CREATE INDEX idx_courses_program ON courses(program_id);
CREATE INDEX idx_enrollments_student ON enrollments(student_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);
CREATE INDEX idx_grades_student_course ON grades(student_id, course_id);
CREATE INDEX idx_faculty_department ON faculty(department_id);
CREATE INDEX idx_attendance_student_course ON attendance(student_id, course_id);
CREATE INDEX idx_assignments_course ON assignments(course_id);
CREATE INDEX idx_submissions_assignment ON assignment_submissions(assignment_id);
CREATE INDEX idx_submissions_student ON assignment_submissions(student_id);
CREATE INDEX idx_loans_student ON book_loans(student_id);
CREATE INDEX idx_loans_book ON book_loans(book_id);
CREATE INDEX idx_transactions_student ON financial_transactions(student_id);

-- Insert sample data for demonstration.
INSERT INTO departments (department_code, department_name, building, phone, email) VALUES
('CS', 'Computer Science', 'Tech Building', '555-0101', 'cs@university.edu'),
('MATH', 'Mathematics', 'Science Building', '555-0102', 'math@university.edu'),
('ENG', 'English', 'Arts Building', '555-0103', 'english@university.edu');

INSERT INTO programs (program_code, program_name, duration_years, total_credits, department_id) VALUES
('BSCS', 'Bachelor of Science in Computer Science', 4, 120, 1),
('BSMATH', 'Bachelor of Science in Mathematics', 4, 120, 2),
('BAENG', 'Bachelor of Arts in English', 4, 120, 3);

INSERT INTO students (student_number, first_name, last_name, date_of_birth, gender, email, phone, address, program_id, enrollment_date) VALUES
('S001', 'John', 'Ede', '2000-05-15', 'Male', 'john.Ede@student.university.edu', '555-1001', '123 Main St', 1, '2023-09-01'),
('S002', 'Jane', 'Smith', '2001-02-20', 'Female', 'jane.smith@student.university.edu', '555-1002', '456 Oak Ave', 1, '2023-09-01'),
('S003', 'Michael', 'Johnson', '2000-11-30', 'Male', 'michael.johnson@student.university.edu', '555-1003', '789 Pine Rd', 2, '2023-09-01');

INSERT INTO faculty (faculty_number, first_name, last_name, email, phone, office_room, department_id, title, hire_date) VALUES
('F001', 'Sarah', 'Wilson', 'sarah.wilson@university.edu', '555-2001', 'TB-101', 1, 'Professor', '2010-08-15'),
('F002', 'David', 'Brown', 'david.brown@university.edu', '555-2002', 'SB-201', 2, 'Associate Professor', '2015-01-20'),
('F003', 'Emily', 'Davis', 'emily.davis@university.edu', '555-2003', 'AB-301', 3, 'Assistant Professor', '2018-03-10');

INSERT INTO courses (course_code, course_name, credits, department_id, program_id, faculty_id, semester, academic_year) VALUES
('CS101', 'Introduction to Programming', 3, 1, 1, 1, 'Fall', 2024),
('CS201', 'Data Structures', 4, 1, 1, 1, 'Fall', 2024),
('MATH101', 'Calculus I', 4, 2, 2, 2, 'Fall', 2024),
('ENG101', 'Composition I', 3, 3, 3, 3, 'Fall', 2024);

-- Insert sample grades to demonstrate the trigger.
INSERT INTO grades (student_id, course_id, faculty_id, grade, grade_date) VALUES
(1, 1, 1, 95.5, '2024-12-15'),
(2, 1, 1, 87.3, '2024-12-15'),
(1, 2, 1, 78.9, '2024-12-16');

-- Display database structure information.
SELECT 'Student Records Management System Database Created Successfully!' AS Status;
SELECT COUNT(*) AS 'Number of Tables Created' FROM information_schema.tables 
WHERE table_schema = 'student_management';

-- Show sample grades with calculated letter grades.
SELECT 
    s.first_name, 
    s.last_name, 
    c.course_code, 
    c.course_name, 
    g.grade, 
    g.letter_grade
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN courses c ON g.course_id = c.course_id;