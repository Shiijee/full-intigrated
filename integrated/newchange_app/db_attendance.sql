-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 10, 2026 at 04:15 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_attendance`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `admin_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `deletion_pin_hash` varchar(255) DEFAULT NULL,
  `failed_attempts` int(11) DEFAULT 0,
  `lockout_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`admin_id`, `username`, `password_hash`, `email`, `deletion_pin_hash`, `failed_attempts`, `lockout_time`) VALUES
(3, 'admin1', 'scrypt:32768:8:1$fbAbd1aYD75fW9TF$602377bb116e872b167a1938ec27d2b97668d1fb6ea51fd13dd8f064c2e923cb6d51c249b4688af9e881d4984c33b0090203592ca5998bf9d5ac109c2abf66ac', 'adminattendeez0218@gmail.com', '021806', 0, NULL),
(4, 'A26-0003', 'scrypt:32768:8:1$3NwwKq8OROLSuzlk$28515f5b979ffcbdbd4eb0af2bff108c9d887d08ebb708b44faf3c81d1838608fa6fefacdae1c5ea1d822555fa24234aab3abe53e50387e48b3bcf34e7e4cced', 'ahahazo@gmail.com', NULL, 0, NULL),
(5, 'A26-0004', 'scrypt:32768:8:1$UgzX0eY0PF8Bbb4H$0aaabb548cf21bd6c47314804a03363414a0e109bfd7c05dd835fc8bfad1193d07525a02dbe5a9532c5df38e3b936c66eb26f4e31eb599f368aee07f7862c128', 'cjhanmao@gmail.com', NULL, 0, NULL),
(6, 'A26-0005', 'scrypt:32768:8:1$E5aOluEapXXRzTAQ$c5588858827f1a98999ddb0c489c30c35cddb21da1718dd73e19548142e16d3e025b120f9d89e6db69c0a84fae5895e8be0dce77ef7a614eece07b00dd050efb', 'asdadaf@gmail.com', NULL, 0, NULL),
(7, 'A26-0006', 'scrypt:32768:8:1$FyXvkXz6SYpUE893$6b3827d04da29a195c44e36a00f0f3fa0f627f7a42a41f63324c0d5c49fca71e2600a52ac25d15d62ed4f6cb5d1824751ff8773d8ff269bf1c25022378c22c9b', 'ahdiabdibavd@gmail.com', NULL, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `attendance_id` int(11) NOT NULL,
  `session_id` varchar(50) NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `scan_time` datetime NOT NULL DEFAULT current_timestamp(),
  `status` varchar(20) DEFAULT 'Present',
  `remarks` varchar(255) DEFAULT NULL,
  `is_valid` varchar(10) DEFAULT 'Valid',
  `student_lat` decimal(10,8) DEFAULT NULL,
  `student_lon` decimal(11,8) DEFAULT NULL,
  `distance_meters` decimal(10,2) DEFAULT NULL,
  `behavior_flags` text DEFAULT NULL,
  `flag_resolution` varchar(20) DEFAULT NULL COMMENT 'pending, accepted, declined - only for Flagged status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `attendance_audit_log`
--

CREATE TABLE `attendance_audit_log` (
  `log_id` int(11) NOT NULL,
  `attendance_id` int(11) DEFAULT NULL,
  `action` varchar(20) NOT NULL,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) DEFAULT NULL,
  `changed_by_user_id` varchar(50) NOT NULL,
  `changed_by_role` varchar(20) NOT NULL,
  `timestamp` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `drop_requests`
--

CREATE TABLE `drop_requests` (
  `request_id` int(11) NOT NULL,
  `teacher_id` varchar(20) NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `reason` text DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Pending',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `enrollments`
--

CREATE TABLE `enrollments` (
  `enrollment_id` int(11) NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `assignment_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `excuse_letters`
--

CREATE TABLE `excuse_letters` (
  `letter_id` int(11) NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `teacher_id` varchar(20) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `message` text NOT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Pending',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `login_logs`
--

CREATE TABLE `login_logs` (
  `log_id` int(11) NOT NULL,
  `user_id` varchar(50) DEFAULT NULL,
  `user_role` varchar(20) DEFAULT NULL,
  `login_time` datetime DEFAULT current_timestamp(),
  `logout_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `login_logs`
--

INSERT INTO `login_logs` (`log_id`, `user_id`, `user_role`, `login_time`, `logout_time`) VALUES
(1, 'S26-0001', 'student', '2026-07-04 21:18:20', '2026-07-04 21:27:30'),
(2, 'S26-0001', 'student', '2026-07-04 21:23:36', '2026-07-04 21:24:52'),
(3, 'S26-0001', 'student', '2026-07-04 21:29:03', NULL),
(4, 'S26-0001', 'student', '2026-07-04 22:10:54', NULL),
(5, 'S26-0001', 'student', '2026-07-04 22:23:27', NULL),
(6, 'S26-0001', 'student', '2026-07-05 11:20:50', '2026-07-05 12:44:36'),
(7, 'T26-0001', 'teacher', '2026-07-05 11:22:04', '2026-07-05 11:27:04'),
(8, 'S26-0001', 'student', '2026-07-05 11:27:16', '2026-07-05 11:36:41'),
(9, 'S26-0001', 'student', '2026-07-05 11:36:01', NULL),
(10, 'T26-0001', 'teacher', '2026-07-05 11:37:37', '2026-07-05 11:38:18'),
(11, '3', 'admin', '2026-07-05 11:38:31', '2026-07-05 11:54:11'),
(12, 'T26-0001', 'teacher', '2026-07-05 11:54:28', '2026-07-05 12:16:27'),
(13, '3', 'admin', '2026-07-05 12:16:38', '2026-07-05 12:17:00'),
(14, 'T26-0001', 'teacher', '2026-07-05 12:17:18', '2026-07-05 12:42:46'),
(15, '3', 'admin', '2026-07-05 12:42:58', NULL),
(16, '3', 'admin', '2026-07-05 12:45:18', NULL),
(17, '3', 'admin', '2026-07-05 13:59:15', '2026-07-05 14:58:23'),
(18, '3', 'admin', '2026-07-05 14:20:23', NULL),
(19, 'S26-0001', 'student', '2026-07-05 14:22:04', NULL),
(20, 'T26-0001', 'teacher', '2026-07-05 14:22:46', '2026-07-05 14:57:16'),
(21, '3', 'admin', '2026-07-05 14:24:08', NULL),
(22, '3', 'admin', '2026-07-05 14:29:57', NULL),
(23, 'S26-0001', 'student', '2026-07-05 14:57:31', '2026-07-05 15:24:48'),
(24, 'T26-0001', 'teacher', '2026-07-05 14:58:46', NULL),
(25, '3', 'admin', '2026-07-05 15:21:28', '2026-07-05 15:21:55'),
(26, 'S26-0001', 'student', '2026-07-05 15:22:18', '2026-07-05 15:23:16'),
(27, 'T26-0001', 'teacher', '2026-07-05 15:23:32', NULL),
(28, '3', 'admin', '2026-07-05 15:25:01', '2026-07-05 15:26:59'),
(29, 'S26-0001', 'student', '2026-07-05 15:27:10', '2026-07-05 15:27:36'),
(30, 'T26-0001', 'teacher', '2026-07-05 15:28:02', '2026-07-05 15:34:22'),
(31, 'S26-0001', 'student', '2026-07-05 15:34:34', '2026-07-05 15:41:19'),
(32, 'S26-0001', 'student', '2026-07-05 15:41:26', NULL),
(33, '3', 'admin', '2026-07-05 21:24:11', NULL),
(34, '3', 'admin', '2026-07-06 13:35:25', NULL),
(35, 'S26-0001', 'student', '2026-07-06 14:05:44', '2026-07-06 14:07:23'),
(36, '3', 'admin', '2026-07-06 14:07:35', '2026-07-06 14:11:08'),
(37, 'T26-0001', 'teacher', '2026-07-06 14:11:23', NULL),
(38, 'S26-0001', 'student', '2026-07-06 14:19:25', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int(11) NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `message` varchar(255) NOT NULL,
  `type` varchar(20) DEFAULT 'Info',
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `otp_lockouts`
--

CREATE TABLE `otp_lockouts` (
  `email` varchar(100) NOT NULL,
  `lockout_until` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `schedule`
--

CREATE TABLE `schedule` (
  `schedule_id` int(11) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `teacher_id` varchar(20) NOT NULL,
  `section` varchar(50) DEFAULT NULL,
  `day_of_week` varchar(20) DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `room` varchar(50) DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `session_id` varchar(50) NOT NULL,
  `teacher_id` varchar(20) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `section` varchar(50) DEFAULT NULL,
  `random_token` varchar(50) NOT NULL,
  `start_time` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Active',
  `is_finalized` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `user_id` varchar(20) NOT NULL,
  `user_role` varchar(20) NOT NULL DEFAULT 'student',
  `first_name` varchar(50) NOT NULL,
  `middle_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `course` varchar(100) DEFAULT NULL,
  `level` varchar(20) DEFAULT NULL,
  `section` varchar(50) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Active',
  `failed_attempts` int(11) DEFAULT 0,
  `lockout_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`user_id`, `user_role`, `first_name`, `middle_name`, `last_name`, `email`, `password_hash`, `course`, `level`, `section`, `status`, `failed_attempts`, `lockout_time`) VALUES
('S26-0001', 'student', 'Juan', 'Dela', 'Cruz', 'juan.delacruz@gmail.com', 'scrypt:32768:8:1$YvgtLmwCFxlUVJIH$a89bb42e588e047de2ce7774de3df9566a225fd3e47fd3cf18077254e2bddc243872c374554785983caac8b15875ff7903423566ba8e908439494693a9872851', 'BSIT', '1st Year', 'A', 'Active', 0, NULL),
('S26-0002', 'student', 'sda', 'adas', 'adas', 'S26-0002@portal.local', 'scrypt:32768:8:1$QzRdmtDX2oGVjaVT$5c3b30df006f5dc32509bc41787b3e85b19cee55634bb7272186a7e0f86b3965d158a29df153153d5a2f2e744090161bcf8a4e2ee5983fb812d186b01a61c000', NULL, NULL, NULL, 'Active', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `subjects`
--

CREATE TABLE `subjects` (
  `subject_id` int(11) NOT NULL,
  `subject_code` varchar(20) NOT NULL,
  `subject_name` varchar(100) NOT NULL,
  `is_archived` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `subjects`
--

INSERT INTO `subjects` (`subject_id`, `subject_code`, `subject_name`, `is_archived`) VALUES
(4, 'IT101', 'Introduction to Computing', 0),
(5, 'IT102', 'Programming 1', 0),
(6, 'IT103', 'Database Management Systems', 0);

-- --------------------------------------------------------

--
-- Table structure for table `submitted_reports`
--

CREATE TABLE `submitted_reports` (
  `report_id` int(11) NOT NULL,
  `teacher_id` varchar(20) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `section` varchar(50) DEFAULT NULL,
  `submission_date` datetime DEFAULT current_timestamp(),
  `summary_json` text DEFAULT NULL,
  `teacher_message` text DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Submitted',
  `is_archived` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_audit_log`
--

CREATE TABLE `system_audit_log` (
  `log_id` int(11) NOT NULL,
  `table_name` varchar(50) NOT NULL,
  `entity_id` varchar(50) NOT NULL,
  `action` varchar(20) NOT NULL,
  `performed_by_id` varchar(50) NOT NULL,
  `performed_by_role` varchar(20) NOT NULL,
  `details` text DEFAULT NULL,
  `timestamp` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `system_audit_log`
--

INSERT INTO `system_audit_log` (`log_id`, `table_name`, `entity_id`, `action`, `performed_by_id`, `performed_by_role`, `details`, `timestamp`) VALUES
(1, 'Sessions', 'session_c1d0518f', 'Create', 'T26-0001', 'teacher', 'QR Session started for Subject 5, Section A', '2026-07-05 11:22:28'),
(2, 'Attendance', '1', 'Create', 'S26-0001', 'student', 'Attendance recorded via QR. Status: Flagged', '2026-07-05 11:22:30'),
(3, 'Sessions', 'session_c1d0518f', 'Update', 'T26-0001', 'teacher', 'Session ended manually', '2026-07-05 11:22:46'),
(4, 'Sessions', 'session_c1d0518f', 'Update', 'T26-0001', 'teacher', 'Attendance finalized/saved for session session_c1d0518f', '2026-07-05 11:23:00'),
(5, 'Teacher_Assignments', '4', 'Create', '3', 'admin', 'Class assigned to teacher T26-0001: Subject ID 5, Section B', '2026-07-05 11:39:02'),
(6, 'Teacher_Assignments', '5', 'Create', '3', 'admin', 'Class assigned to teacher T26-0001: Subject ID 6, Section B', '2026-07-05 11:39:26'),
(7, 'schedule', '1', 'Create', '3', 'admin', 'Schedule created for 6 - B on Monday (10:00-12:00)', '2026-07-05 11:39:59'),
(8, 'schedule', '2', 'Create', '3', 'admin', 'Schedule created for 5 - A on Wednesday (07:00-10:00)', '2026-07-05 11:40:52'),
(9, 'schedule', '3', 'Create', '3', 'admin', 'Schedule created for 5 - A on Wednesday (07:00-10:00)', '2026-07-05 11:40:59'),
(10, 'Enrollments', '4', 'Create', '3', 'admin', 'Manual Enrollment: Student S26-0001 enrolled in Assignment ID 5', '2026-07-05 12:16:50'),
(11, 'Sessions', 'session_c1490a63', 'Create', 'T26-0001', 'teacher', 'QR Session started for Subject 6, Section B', '2026-07-05 12:17:42'),
(12, 'Attendance', '2', 'Create', 'S26-0001', 'student', 'Attendance recorded via QR. Status: Flagged', '2026-07-05 12:17:49'),
(13, 'Sessions', 'session_c1490a63', 'Update', 'T26-0001', 'teacher', 'Session ended manually', '2026-07-05 12:18:03'),
(14, 'Attendance', '2', 'Update', 'T26-0001', 'teacher', 'Flagged attendance accepted and changed to Present', '2026-07-05 12:24:52'),
(15, 'Sessions', 'session_c1490a63', 'Update', 'T26-0001', 'teacher', 'Attendance finalized/saved for session session_c1490a63', '2026-07-05 12:25:03'),
(16, 'teacher_assignments', '5', 'Update', '3', 'admin', 'Assignment archived (ID: 5)', '2026-07-05 13:17:28'),
(17, 'teacher_assignments', '5', 'Update', '3', 'admin', 'Assignment unarchived (ID: 5)', '2026-07-05 13:17:34'),
(18, 'Sessions', 'session_3cb800d8', 'Create', 'T26-0001', 'teacher', 'QR Session started for Subject 6, Section B', '2026-07-06 14:20:12'),
(19, 'Attendance', '3', 'Create', 'S26-0001', 'student', 'Attendance recorded via QR. Status: Present', '2026-07-06 14:20:29'),
(20, 'Sessions', 'session_3cb800d8', 'Update', 'T26-0001', 'teacher', 'Session ended manually', '2026-07-06 14:20:51'),
(21, 'Sessions', 'session_3cb800d8', 'Update', 'T26-0001', 'teacher', 'Attendance finalized/saved for session session_3cb800d8', '2026-07-06 14:21:01');

-- --------------------------------------------------------

--
-- Table structure for table `teachers`
--

CREATE TABLE `teachers` (
  `user_id` varchar(20) NOT NULL,
  `user_role` varchar(20) NOT NULL DEFAULT 'teacher',
  `first_name` varchar(50) NOT NULL,
  `middle_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `status` varchar(20) DEFAULT 'Active',
  `failed_attempts` int(11) DEFAULT 0,
  `lockout_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `teachers`
--

INSERT INTO `teachers` (`user_id`, `user_role`, `first_name`, `middle_name`, `last_name`, `department`, `email`, `password_hash`, `status`, `failed_attempts`, `lockout_time`) VALUES
('T26-0001', 'teacher', 'Cj Han', 'Nomo', 'Matienzo', NULL, 'cjhanenzo@gmail.com', '<paste the password_hash from db_portal for T26-0001>', 'Active', 0, NULL),
('T26-0003', 'teacher', 'Cj', 'No', 'Maenzo', NULL, 'cjhano@gmail.com', 'scrypt:32768:8:1$FnLUfDqgaFnrZtEQ$e8a90d99b0448998ba3cd945f67e589acf28ef497dc5c7fda29701fb84153a842c7eae19dca7894c81e7af8a404f039b91f213c5fca0eb386a508de04223ccd3', 'Active', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `teacher_assignments`
--

CREATE TABLE `teacher_assignments` (
  `assignment_id` int(11) NOT NULL,
  `teacher_id` varchar(20) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `section` varchar(50) DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`attendance_id`),
  ADD UNIQUE KEY `session_id` (`session_id`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `attendance_audit_log`
--
ALTER TABLE `attendance_audit_log`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `drop_requests`
--
ALTER TABLE `drop_requests`
  ADD PRIMARY KEY (`request_id`),
  ADD KEY `teacher_id` (`teacher_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `subject_id` (`subject_id`);

--
-- Indexes for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD PRIMARY KEY (`enrollment_id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`assignment_id`),
  ADD KEY `assignment_id` (`assignment_id`);

--
-- Indexes for table `excuse_letters`
--
ALTER TABLE `excuse_letters`
  ADD PRIMARY KEY (`letter_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `teacher_id` (`teacher_id`),
  ADD KEY `subject_id` (`subject_id`);

--
-- Indexes for table `login_logs`
--
ALTER TABLE `login_logs`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `otp_lockouts`
--
ALTER TABLE `otp_lockouts`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `schedule`
--
ALTER TABLE `schedule`
  ADD PRIMARY KEY (`schedule_id`),
  ADD KEY `subject_id` (`subject_id`),
  ADD KEY `teacher_id` (`teacher_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`session_id`),
  ADD KEY `teacher_id` (`teacher_id`),
  ADD KEY `subject_id` (`subject_id`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`subject_id`),
  ADD UNIQUE KEY `subject_code` (`subject_code`);

--
-- Indexes for table `submitted_reports`
--
ALTER TABLE `submitted_reports`
  ADD PRIMARY KEY (`report_id`),
  ADD KEY `teacher_id` (`teacher_id`),
  ADD KEY `subject_id` (`subject_id`);

--
-- Indexes for table `system_audit_log`
--
ALTER TABLE `system_audit_log`
  ADD PRIMARY KEY (`log_id`);

--
-- Indexes for table `teachers`
--
ALTER TABLE `teachers`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `teacher_assignments`
--
ALTER TABLE `teacher_assignments`
  ADD PRIMARY KEY (`assignment_id`),
  ADD UNIQUE KEY `teacher_id` (`teacher_id`,`subject_id`,`section`),
  ADD KEY `subject_id` (`subject_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `attendance_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `attendance_audit_log`
--
ALTER TABLE `attendance_audit_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `drop_requests`
--
ALTER TABLE `drop_requests`
  MODIFY `request_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `enrollments`
--
ALTER TABLE `enrollments`
  MODIFY `enrollment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `excuse_letters`
--
ALTER TABLE `excuse_letters`
  MODIFY `letter_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `login_logs`
--
ALTER TABLE `login_logs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `schedule`
--
ALTER TABLE `schedule`
  MODIFY `schedule_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `subject_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `submitted_reports`
--
ALTER TABLE `submitted_reports`
  MODIFY `report_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_audit_log`
--
ALTER TABLE `system_audit_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `teacher_assignments`
--
ALTER TABLE `teacher_assignments`
  MODIFY `assignment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `attendance`
--
ALTER TABLE `attendance`
  ADD CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`session_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `attendance_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `students` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `drop_requests`
--
ALTER TABLE `drop_requests`
  ADD CONSTRAINT `drop_requests_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `drop_requests_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `students` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `drop_requests_ibfk_3` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE;

--
-- Constraints for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD CONSTRAINT `enrollments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `students` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `enrollments_ibfk_2` FOREIGN KEY (`assignment_id`) REFERENCES `teacher_assignments` (`assignment_id`) ON DELETE CASCADE;

--
-- Constraints for table `excuse_letters`
--
ALTER TABLE `excuse_letters`
  ADD CONSTRAINT `excuse_letters_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `students` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `excuse_letters_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `excuse_letters_ibfk_3` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `students` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `schedule`
--
ALTER TABLE `schedule`
  ADD CONSTRAINT `schedule_ibfk_1` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `schedule_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `sessions`
--
ALTER TABLE `sessions`
  ADD CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `sessions_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE;

--
-- Constraints for table `submitted_reports`
--
ALTER TABLE `submitted_reports`
  ADD CONSTRAINT `submitted_reports_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `submitted_reports_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE;

--
-- Constraints for table `teacher_assignments`
--
ALTER TABLE `teacher_assignments`
  ADD CONSTRAINT `teacher_assignments_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `teacher_assignments_ibfk_2` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`subject_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
