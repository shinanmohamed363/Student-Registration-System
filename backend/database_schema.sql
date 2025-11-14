-- Student Registration System Database Schema
-- Database: studentregistrationsystemdb
-- Charset: utf8mb4

-- Drop existing tables if they exist (for clean setup)
DROP TABLE IF EXISTS student_assignments;
DROP TABLE IF EXISTS assignments;
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;

-- Students table
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    date_of_birth DATE,
    profile_picture VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_student_id (student_id),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Courses table
CREATE TABLE courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) UNIQUE NOT NULL,
    course_name VARCHAR(100) NOT NULL,
    description TEXT,
    credits INT NOT NULL DEFAULT 3,
    instructor VARCHAR(100),
    max_students INT DEFAULT 50,
    current_students INT DEFAULT 0,
    prerequisites TEXT,
    schedule VARCHAR(100),
    semester VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_course_code (course_code),
    INDEX idx_semester (semester)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Enrollments table
CREATE TABLE enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    grade VARCHAR(2),
    status ENUM('active', 'completed', 'dropped') DEFAULT 'active',
    final_marks DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (student_id, course_id),
    INDEX idx_student (student_id),
    INDEX idx_course (course_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Assignments table
CREATE TABLE assignments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    assignment_name VARCHAR(100) NOT NULL,
    description TEXT,
    max_marks DECIMAL(5,2) NOT NULL,
    due_date DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    INDEX idx_course (course_id),
    INDEX idx_due_date (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Student Assignments table
CREATE TABLE student_assignments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    enrollment_id INT NOT NULL,
    assignment_id INT NOT NULL,
    marks DECIMAL(5,2),
    submitted_at TIMESTAMP NULL,
    submission_file VARCHAR(255),
    feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(id) ON DELETE CASCADE,
    FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
    UNIQUE KEY unique_submission (enrollment_id, assignment_id),
    INDEX idx_enrollment (enrollment_id),
    INDEX idx_assignment (assignment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample data
-- Sample students (passwords are hashed version of 'password123')
INSERT INTO students (student_id, name, email, password_hash, phone, date_of_birth) VALUES
('STU001', 'John Doe', 'john.doe@student.com', '$2a$10$rN8qz3Z6z3Z6z3Z6z3Z6z.VKZ4rN8qz3Z6z3Z6z3Z6z3Z6z3Z6z3Z', '1234567890', '2000-01-15'),
('STU002', 'Jane Smith', 'jane.smith@student.com', '$2a$10$rN8qz3Z6z3Z6z3Z6z3Z6z.VKZ4rN8qz3Z6z3Z6z3Z6z3Z6z3Z6z3Z', '0987654321', '2001-03-20');

-- Sample courses
INSERT INTO courses (course_code, course_name, description, credits, instructor, max_students, semester, schedule) VALUES
('CS101', 'Introduction to Programming', 'Learn the fundamentals of programming using Python', 4, 'Dr. Smith', 50, 'Fall 2024', 'Mon/Wed 9:00-10:30'),
('CS102', 'Data Structures', 'Study common data structures and algorithms', 4, 'Dr. Johnson', 45, 'Fall 2024', 'Tue/Thu 10:00-11:30'),
('MATH201', 'Calculus I', 'Introduction to differential and integral calculus', 3, 'Prof. Williams', 60, 'Fall 2024', 'Mon/Wed/Fri 11:00-12:00'),
('ENG101', 'English Composition', 'Develop writing and communication skills', 3, 'Dr. Brown', 40, 'Fall 2024', 'Tue/Thu 13:00-14:30'),
('CS201', 'Database Systems', 'Learn database design and SQL', 4, 'Dr. Davis', 40, 'Fall 2024', 'Mon/Wed 14:00-15:30');

-- Sample enrollments
INSERT INTO enrollments (student_id, course_id, status) VALUES
(1, 1, 'active'),
(1, 3, 'active'),
(2, 1, 'active'),
(2, 2, 'active');

-- Sample assignments
INSERT INTO assignments (course_id, assignment_name, description, max_marks, due_date) VALUES
(1, 'Assignment 1: Variables and Data Types', 'Complete exercises on variables and data types', 100, '2024-09-30 23:59:59'),
(1, 'Assignment 2: Control Structures', 'Implement programs using loops and conditionals', 100, '2024-10-15 23:59:59'),
(2, 'Assignment 1: Arrays and Lists', 'Implement various array operations', 100, '2024-10-01 23:59:59');

-- Sample student assignment submissions
INSERT INTO student_assignments (enrollment_id, assignment_id, marks, submitted_at) VALUES
(1, 1, 85.00, '2024-09-28 15:30:00'),
(1, 2, 92.00, '2024-10-14 20:15:00'),
(3, 1, 78.00, '2024-09-29 18:45:00');
