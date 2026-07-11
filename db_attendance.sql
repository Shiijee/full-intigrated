-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 09, 2026 at 02:08 PM
-- Server version: 8.0.43
-- PHP Version: 8.3.30

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
  `admin_id` int NOT NULL,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `deletion_pin_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `failed_attempts` int DEFAULT '0',
  `lockout_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`admin_id`, `username`, `password_hash`, `email`, `deletion_pin_hash`, `failed_attempts`, `lockout_time`) VALUES
(3, 'A26-0001', 'scrypt:32768:8:1$fbAbd1aYD75fW9TF$602377bb116e872b167a1938ec27d2b97668d1fb6ea51fd13dd8f064c2e923cb6d51c249b4688af9e881d4984c33b0090203592ca5998bf9d5ac109c2abf66ac', 'adminattendeez0218@gmail.com', '021806', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `attendance_id` int NOT NULL,
  `session_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `scan_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Present',
  `remarks` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_valid` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Valid',
  `student_lat` decimal(10,8) DEFAULT NULL,
  `student_lon` decimal(11,8) DEFAULT NULL,
  `distance_meters` decimal(10,2) DEFAULT NULL,
  `behavior_flags` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `flag_resolution` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'pending, accepted, declined - only for Flagged status'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `attendance`
--

INSERT INTO `attendance` (`attendance_id`, `session_id`, `user_id`, `scan_time`, `status`, `remarks`, `is_valid`, `student_lat`, `student_lon`, `distance_meters`, `behavior_flags`, `flag_resolution`) VALUES
(1, 'session_c1d0518f', 'S26-0001', '2026-07-05 11:22:30', 'Flagged', 'Distance: 396m', 'Invalid', 14.23342390, 121.36284880, 395.85, '[\"Far Location: 396m\"]', NULL),
(2, 'session_c1490a63', 'S26-0001', '2026-07-05 12:17:49', 'Present', 'Flagged attendance accepted by teacher', 'Invalid', 14.23342200, 121.36284430, 391.29, '[\"Far Location: 391m\"]', 'accepted'),
(3, 'session_3cb800d8', 'S26-0001', '2026-07-06 14:20:29', 'Present', 'Distance: 51m', 'Valid', 14.25498330, 121.40762400, 50.67, '[]', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `attendance_audit_log`
--

CREATE TABLE `attendance_audit_log` (
  `log_id` int NOT NULL,
  `attendance_id` int DEFAULT NULL,
  `action` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `old_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `new_status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `changed_by_user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `changed_by_role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `drop_requests`
--

CREATE TABLE `drop_requests` (
  `request_id` int NOT NULL,
  `teacher_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject_id` int NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `enrollments`
--

CREATE TABLE `enrollments` (
  `enrollment_id` int NOT NULL,
  `user_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `assignment_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `enrollments`
--

INSERT INTO `enrollments` (`enrollment_id`, `user_id`, `assignment_id`) VALUES
(4, 'S26-0001', 5);

-- --------------------------------------------------------

--
-- Table structure for table `excuse_letters`
--

CREATE TABLE `excuse_letters` (
  `letter_id` int NOT NULL,
  `user_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `teacher_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject_id` int NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Pending',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `login_logs`
--

CREATE TABLE `login_logs` (
  `log_id` int NOT NULL,
  `user_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `login_time` datetime DEFAULT CURRENT_TIMESTAMP,
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
  `notification_id` int NOT NULL,
  `user_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Info',
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `otp_lockouts`
--

CREATE TABLE `otp_lockouts` (
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `lockout_until` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `schedule`
--

CREATE TABLE `schedule` (
  `schedule_id` int NOT NULL,
  `subject_id` int NOT NULL,
  `teacher_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `section` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `day_of_week` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `room` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `schedule`
--

INSERT INTO `schedule` (`schedule_id`, `subject_id`, `teacher_id`, `section`, `day_of_week`, `start_time`, `end_time`, `room`, `is_archived`) VALUES
(1, 6, 'T26-0001', 'B', 'Monday', '10:00:00', '12:00:00', 'LABU2', 0),
(3, 5, 'T26-0001', 'A', 'Wednesday', '07:00:00', '10:00:00', 'LABU3', 0);

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `session_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `teacher_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject_id` int NOT NULL,
  `section` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `random_token` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_time` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Active',
  `is_finalized` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`session_id`, `teacher_id`, `subject_id`, `section`, `random_token`, `start_time`, `expires_at`, `latitude`, `longitude`, `status`, `is_finalized`) VALUES
('session_3cb800d8', 'T26-0001', 6, 'B', 'FdzuhMuDBz', '2026-07-06 14:20:12', '2026-07-06 14:30:12', 14.25533650, 121.40792100, 'Ended', 1),
('session_c1490a63', 'T26-0001', 6, 'B', 'sAWX2KA3Mn', '2026-07-05 12:17:43', '2026-07-05 12:22:43', 14.23401400, 121.36642300, 'Ended', 1),
('session_c1d0518f', 'T26-0001', 5, 'A', 'Jcd2oPa5Io', '2026-07-05 11:22:29', '2026-07-05 11:27:29', 14.23402400, 121.36646900, 'Ended', 1);

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `user_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'student',
  `first_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `middle_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `course` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `level` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `section` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Active',
  `failed_attempts` int DEFAULT '0',
  `lockout_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`user_id`, `user_role`, `first_name`, `middle_name`, `last_name`, `email`, `password_hash`, `course`, `level`, `section`, `status`, `failed_attempts`, `lockout_time`) VALUES
('S26-0001', 'student', 'Juan', 'Dela', 'Cruz', 'juan.delacruz@gmail.com', 'scrypt:32768:8:1$YvgtLmwCFxlUVJIH$a89bb42e588e047de2ce7774de3df9566a225fd3e47fd3cf18077254e2bddc243872c374554785983caac8b15875ff7903423566ba8e908439494693a9872851', 'BSIT', '1st Year', 'A', 'Active', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `subjects`
--

CREATE TABLE `subjects` (
  `subject_id` int NOT NULL,
  `subject_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_archived` tinyint(1) DEFAULT '0'
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
  `report_id` int NOT NULL,
  `teacher_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject_id` int NOT NULL,
  `section` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `submission_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `summary_json` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `teacher_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Submitted',
  `is_archived` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_audit_log`
--

CREATE TABLE `system_audit_log` (
  `log_id` int NOT NULL,
  `table_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `performed_by_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `performed_by_role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
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
  `user_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'teacher',
  `first_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `middle_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'Active',
  `failed_attempts` int DEFAULT '0',
  `lockout_time` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `teachers`
--

INSERT INTO `teachers` (`user_id`, `user_role`, `first_name`, `middle_name`, `last_name`, `department`, `email`, `password_hash`, `status`, `failed_attempts`, `lockout_time`) VALUES
('T26-0001', 'teacher', 'Maria', 'Santos', 'Reyes', 'Information Technology', 'maria.reyes@gmail.com', 'scrypt:32768:8:1$YvgtLmwCFxlUVJIH$a89bb42e588e047de2ce7774de3df9566a225fd3e47fd3cf18077254e2bddc243872c374554785983caac8b15875ff7903423566ba8e908439494693a9872851', 'Active', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `teacher_assignments`
--

CREATE TABLE `teacher_assignments` (
  `assignment_id` int NOT NULL,
  `teacher_id` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject_id` int NOT NULL,
  `section` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `teacher_assignments`
--

INSERT INTO `teacher_assignments` (`assignment_id`, `teacher_id`, `subject_id`, `section`, `is_archived`) VALUES
(5, 'T26-0001', 6, 'B', 0);

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
  MODIFY `admin_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `attendance_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `attendance_audit_log`
--
ALTER TABLE `attendance_audit_log`
  MODIFY `log_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `drop_requests`
--
ALTER TABLE `drop_requests`
  MODIFY `request_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `enrollments`
--
ALTER TABLE `enrollments`
  MODIFY `enrollment_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `excuse_letters`
--
ALTER TABLE `excuse_letters`
  MODIFY `letter_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `login_logs`
--
ALTER TABLE `login_logs`
  MODIFY `log_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `schedule`
--
ALTER TABLE `schedule`
  MODIFY `schedule_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `subject_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `submitted_reports`
--
ALTER TABLE `submitted_reports`
  MODIFY `report_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_audit_log`
--
ALTER TABLE `system_audit_log`
  MODIFY `log_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `teacher_assignments`
--
ALTER TABLE `teacher_assignments`
  MODIFY `assignment_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
