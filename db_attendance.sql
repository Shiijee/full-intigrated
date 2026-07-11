-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 11, 2026 at 03:11 PM
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
(4, 'A26-0003', 'scrypt:32768:8:1$59h7uJ3ECXmixJd3$c4a74e2d1e0785a91dca8eef3fd9b5259cb4431500d464e9e73a26c79352e7e5aca70de1875d4586db89308d9f13aa3b1d1cfec94f2befb1a14ae4d2bdf683a1', 'ahahazo@gmail.com', NULL, 0, NULL),
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

--
-- Dumping data for table `attendance`
--

INSERT INTO `attendance` (`attendance_id`, `session_id`, `user_id`, `scan_time`, `status`, `remarks`, `is_valid`, `student_lat`, `student_lon`, `distance_meters`, `behavior_flags`, `flag_resolution`) VALUES
(4, 'MANUAL-3d382e3b', 'S26-0006', '2026-07-11 15:02:00', 'Present', 'Manual attendance by teacher', 'Valid', NULL, NULL, NULL, NULL, NULL);

--
-- Triggers `attendance`
--
DELIMITER $$
CREATE TRIGGER `after_attendance_insert` AFTER INSERT ON `attendance` FOR EACH ROW BEGIN
    DECLARE subj_code VARCHAR(50);
    
    
    SELECT s.subject_code INTO subj_code
    FROM sessions ses
    JOIN Subjects s ON ses.subject_id = s.subject_id
    WHERE ses.session_id = NEW.session_id LIMIT 1;
    
    INSERT INTO Notifications (user_id, message, type)
    VALUES (NEW.user_id, CONCAT('Your attendance for ', IFNULL(subj_code, 'a class'), ' has been recorded as ', NEW.status, '.'), 'Info');
END
$$
DELIMITER ;

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

--
-- Dumping data for table `enrollments`
--

INSERT INTO `enrollments` (`enrollment_id`, `user_id`, `assignment_id`) VALUES
(5, 'S26-0006', 6),
(6, 'S26-0006', 7);

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

--
-- Dumping data for table `excuse_letters`
--

INSERT INTO `excuse_letters` (`letter_id`, `user_id`, `teacher_id`, `subject_id`, `message`, `file_path`, `status`, `created_at`) VALUES
(3, 'S26-0006', 'T26-0003', 7, 'asdasd', 'S26-0006_20260711182627_d13d8af8-7fe9-4eba-92d3-0cf967212ddb.jpg', 'Approved', '2026-07-11 18:26:27'),
(4, 'S26-0006', 'T26-0003', 7, 'hotdog', 'S26-0006_20260711183257_d13d8af8-7fe9-4eba-92d3-0cf967212ddb.jpg', 'Approved', '2026-07-11 18:32:57');

--
-- Triggers `excuse_letters`
--
DELIMITER $$
CREATE TRIGGER `after_excuse_update` AFTER UPDATE ON `excuse_letters` FOR EACH ROW BEGIN
    DECLARE subj_code VARCHAR(50);
    IF NEW.status != OLD.status AND NEW.status IN ('Approved', 'Rejected') THEN
        SELECT subject_code INTO subj_code FROM Subjects WHERE subject_id = NEW.subject_id LIMIT 1;
        
        INSERT INTO Notifications (user_id, message, type)
        VALUES (NEW.user_id, CONCAT('Your excuse letter for ', IFNULL(subj_code, 'a class'), ' has been ', LOWER(NEW.status), '.'), 'Info');
    END IF;
END
$$
DELIMITER ;

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

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`notification_id`, `user_id`, `message`, `type`, `is_read`, `created_at`) VALUES
(1, 'S26-0006', 'Your excuse letter for CC1203 has been approved.', 'Info', 0, '2026-07-11 19:07:00');

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

--
-- Dumping data for table `schedule`
--

INSERT INTO `schedule` (`schedule_id`, `subject_id`, `teacher_id`, `section`, `day_of_week`, `start_time`, `end_time`, `room`, `is_archived`) VALUES
(4, 7, 'T26-0003', '2A', 'Thursday', '10:00:00', '17:00:00', 'LABU3', 0),
(5, 13, 'T26-0001', '2A', 'Saturday', '07:49:00', '16:51:00', 'labu3', 0);

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

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`session_id`, `teacher_id`, `subject_id`, `section`, `random_token`, `start_time`, `expires_at`, `latitude`, `longitude`, `status`, `is_finalized`) VALUES
('MANUAL-3d382e3b', 'T26-0003', 7, '2A', 'MANUAL', '2026-07-11 15:02:00', '2026-07-11 15:02:00', 0.00000000, 0.00000000, 'Ended', 1),
('session_87c8ca69', 'T26-0001', 13, '2A', 'qUbTGqd3z8', '2026-07-11 15:56:30', '2026-07-11 16:06:30', 14.25601356, 121.40086615, 'Active', 0);

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
  `program` varchar(100) DEFAULT NULL,
  `year` varchar(50) DEFAULT NULL,
  `block` varchar(50) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Active',
  `failed_attempts` int(11) DEFAULT 0,
  `lockout_time` datetime DEFAULT NULL,
  `college` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`user_id`, `user_role`, `first_name`, `middle_name`, `last_name`, `email`, `password_hash`, `program`, `year`, `block`, `status`, `failed_attempts`, `lockout_time`, `college`) VALUES
('S26-0001', 'student', 'Cj', 'Han Nomo', 'Matienzo', 'arnzo@gmail.com', 'scrypt:32768:8:1$YvgtLmwCFxlUVJIH$a89bb42e588e047de2ce7774de3df9566a225fd3e47fd3cf18077254e2bddc243872c374554785983caac8b15875ff7903423566ba8e908439494693a9872851', 'BSIT-SD', '', '2A', 'Active', 0, NULL, NULL),
('S26-0002', 'student', 'sda', 'adas', 'adas', 'adaa@gmail.com', 'scrypt:32768:8:1$QzRdmtDX2oGVjaVT$5c3b30df006f5dc32509bc41787b3e85b19cee55634bb7272186a7e0f86b3965d158a29df153153d5a2f2e744090161bcf8a4e2ee5983fb812d186b01a61c000', 'BSIT-SD', '', '2A', 'Active', 0, NULL, NULL),
('S26-0003', 'student', 'Joan', 'Sidamon', 'Gutiza', 'jgutiza30@gmail.com', 'scrypt:32768:8:1$HqD2HVg4FSepa6FG$7d8e3910ac56d15104b5c7304d6a811100f57de669bb7cd1633e8636984c4827d28383f21306d0d51ef84a182c648f36089dc7aacf71088e97112a1fd10e9ee5', 'BSCS', '', '1A', 'Active', 0, NULL, 'CCS'),
('S26-0004', 'student', 'Onin', '', 'Napiza', 'oninnapiza4@gmail.com', 'scrypt:32768:8:1$jOUCyXTrWlEJrvOT$3250c9b81f3d8a0bac9d65dfb63fde71653bea214b00ba008ea8335a8d29153e80e88a40a6a3aae815a591859d3a6033699981c8537ecec1d13b2cae4a15ecd2', 'BSSSS', '', '1A', 'Active', 0, NULL, 'CCS'),
('S26-0005', 'student', 'Xzon', '', 'Guinto', 'gutizaaudie1@gmail.com', 'scrypt:32768:8:1$6tQ9ziIYKBnEYmq6$e1dd2a738389126bcd8fc5ac13bb4a7995e246923f036818646903b67e8926db34f6a6c30bf4617aa12dc72c51aa76b345a9d41621de97aed3ce5318cba63fa5', 'BSCS', '', '1A', 'Active', 0, NULL, 'CCS'),
('S26-0006', 'student', 'Xzone', 'Nazarene', 'Ginto', 'xzoneginto@gmail.com', 'scrypt:32768:8:1$z4bstHJHvS1rwq8Y$f7190e654ca6bffdda342904b1caafc38c9960cc698f6a50fd2884f92f012eb01dace5631c2ea5718d25767edd14ecb189c7a678c96816da63855a11dd8acc72', 'BSED', '', '2A', 'Active', 0, NULL, 'COED');

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
(6, 'IT103', 'Database Management Systems', 0),
(7, 'CC1203', 'Introduction to Education', 0),
(8, 'CC-1100', 'Introduction to Computing', 0),
(9, 'IT-2206', 'Database Management System', 0),
(10, 'IT-2208', 'Quantitative Methods', 0),
(11, 'IT-2211', 'Integrative Programming and Technologies 2', 0),
(12, 'ME 1', 'Mechanical Engineering', 0),
(13, 'COED1Q', 'COED SUBJECT TEST', 0);

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
(21, 'Sessions', 'session_3cb800d8', 'Update', 'T26-0001', 'teacher', 'Attendance finalized/saved for session session_3cb800d8', '2026-07-06 14:21:01'),
(22, 'Students', 'S26-0004', 'Update', 'A26-0003', 'admin', 'Student archived: S26-0004', '2026-07-11 04:14:53'),
(23, 'Students', 'S26-0004', 'Update', 'A26-0003', 'admin', 'Student unarchived: S26-0004', '2026-07-11 04:15:12'),
(24, 'schedule', '4', 'Create', 'A26-0003', 'admin', 'Schedule created for 7 - 2A on Thursday (10:00-17:00)', '2026-07-11 14:25:45'),
(25, 'Sessions', 'MANUAL-3d382e3b', 'Create', 'T26-0003', 'teacher', 'Manual session created for Subject 7, Section 2A', '2026-07-11 15:02:00'),
(26, 'Sessions', 'MANUAL-3d382e3b', 'Update', 'T26-0003', 'teacher', 'Attendance finalized/saved for session MANUAL-3d382e3b', '2026-07-11 15:08:38'),
(27, 'schedule', '5', 'Create', 'A26-0003', 'admin', 'Schedule created for 13 - 2A on Saturday (07:49-16:51)', '2026-07-11 15:50:13'),
(28, 'Sessions', 'session_87c8ca69', 'Create', 'T26-0001', 'teacher', 'QR Session started for Subject 13, Section 2A', '2026-07-11 15:56:30'),
(29, 'Excuse_Letters', '3', 'Create', 'S26-0006', 'student', 'Excuse letter submitted for Subject 7', '2026-07-11 18:26:27'),
(30, 'Excuse_Letters', '4', 'Create', 'S26-0006', 'student', 'Excuse letter submitted for Subject 7', '2026-07-11 18:32:57'),
(31, 'Excuse_Letters', '4', 'Update', 'T26-0003', 'teacher', 'Excuse letter status updated to Approved', '2026-07-11 18:54:13'),
(32, 'Excuse_Letters', '3', 'Update', 'T26-0003', 'teacher', 'Excuse letter status updated to Approved', '2026-07-11 19:07:00');

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
('T26-0001', 'teacher', 'Cj', 'Han Nomo', 'Matienzo', 'COED', 'cjhanenzo@gmail.com', '<paste the password_hash from db_portal for T26-0001>', 'Active', 0, NULL),
('T26-0002', 'teacher', 'Cj', 'Nomo', 'Matienzo', 'Faculty', 'cjhanmanzo@gmail.com', 'scrypt:32768:8:1$ckQJ21SK16873CO9$9dea696809a8e588105e3b4bcd4ba8d8388321a7996a68e3d40b1f398795309aa39ebabaeb939ac0dd95c43d800697adcbe549c60a80c63f0346d1bd74d3f7ae', 'Active', 0, NULL),
('T26-0003', 'teacher', 'Cj', 'No', 'Maenzo', 'Faculty', 'cjhano@gmail.com', 'scrypt:32768:8:1$FnLUfDqgaFnrZtEQ$e8a90d99b0448998ba3cd945f67e589acf28ef497dc5c7fda29701fb84153a842c7eae19dca7894c81e7af8a404f039b91f213c5fca0eb386a508de04223ccd3', 'Active', 0, NULL),
('T26-0004', 'teacher', 'John', 'Andrei Sidamon', 'Napiza', 'CCS', 'johnandreisidamongutiza@gmail.com', 'scrypt:32768:8:1$UNpnbxnD4SUFGtcT$05a9f698bd70141261534bfdeddc41f7a1add7ae835faba1d5e591a6ce5629d59cad3adbd69e98afdd6c71c90de51cae771f5dd06d31b096971ab13e4fdf6a59', 'Active', 0, NULL),
('T26-0005', 'teacher', 'John', 'Andrei', 'gutiza', '', 'johnandreisidamongutizaa@gmail.com', 'scrypt:32768:8:1$hLVDc3xJYS2MNSq8$da95e6c24c1359614a9fc02f7631d407264025fbac679fc7077703644d55899ac8f8655dbfc41f9bf1db7809f61215768fe18d37558b2d08833034cc932dbe69', 'Active', 0, NULL),
('T26-0006', 'teacher', 'John', 'Andrei', 'gutizas', '', 'jgutiza301@gmail.com', 'scrypt:32768:8:1$iTVZIsIFzmop6DBD$7ecabab9a8a69b804a0ded1839b61976d05fc86761e8ea187d78ff659151ed46157f2c84149891ec2b67213a2b0804621d9e2909bd6095402b2310834863fcb8', 'Active', 0, NULL),
('T26-0007', 'teacher', 'Onin', '', 'napizas', 'CCS', 'oninnapiza41@gmail.com', 'scrypt:32768:8:1$X0hYlIWjv4ffxkv1$bc337728406452ff89bbc0081fad4c40edf456b0ea61d849a1d47e0405d7cde4263922b3eab546ba97d1aebae8f92a27140a6e74ebefe04fd4913826148bc138', 'Active', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `teacher_assignments`
--

CREATE TABLE `teacher_assignments` (
  `assignment_id` int(11) NOT NULL,
  `teacher_id` varchar(20) NOT NULL,
  `subject_id` int(11) NOT NULL,
  `section` varchar(50) DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT 0,
  `class_code` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `teacher_assignments`
--

INSERT INTO `teacher_assignments` (`assignment_id`, `teacher_id`, `subject_id`, `section`, `is_archived`, `class_code`) VALUES
(6, 'T26-0003', 7, '2A', 0, '#101'),
(7, 'T26-0001', 13, '2A', 0, '#102'),
(8, 'T26-0005', 11, '1A', 0, '#103'),
(9, 'T26-0006', 9, '1A', 0, '#104'),
(10, 'T26-0007', 11, '1A', 0, '#105');

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
  ADD UNIQUE KEY `class_code` (`class_code`),
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
  MODIFY `attendance_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
  MODIFY `enrollment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `excuse_letters`
--
ALTER TABLE `excuse_letters`
  MODIFY `letter_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `login_logs`
--
ALTER TABLE `login_logs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `schedule`
--
ALTER TABLE `schedule`
  MODIFY `schedule_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `subject_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `submitted_reports`
--
ALTER TABLE `submitted_reports`
  MODIFY `report_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_audit_log`
--
ALTER TABLE `system_audit_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `teacher_assignments`
--
ALTER TABLE `teacher_assignments`
  MODIFY `assignment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

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
