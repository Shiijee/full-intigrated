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
-- Database: `db_exam`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `admin_id` varchar(10) NOT NULL,
  `email` varchar(200) NOT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `middlename` varchar(50) DEFAULT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  `region` varchar(200) DEFAULT NULL,
  `province` varchar(200) DEFAULT NULL,
  `city` varchar(200) DEFAULT NULL,
  `barangay` varchar(200) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`admin_id`, `email`, `firstname`, `middlename`, `lastname`, `region`, `province`, `city`, `barangay`) VALUES
('A26-0000', 'justindion180@gmail.com', 'Justin Dion', 'Bibon', 'Salaveria', 'Region IV-A (CALABARZON)', 'Laguna', 'Santa Cruz (Capital)', 'Labuin'),
('A26-0002', 'cjmatienzo@gmail.com', 'Asia', 'Pas', 'Asis', 'Region II (Cagayan Valley)', 'Isabela', 'Echague', 'Dammang East'),
('A26-0003', 'ahahazo@gmail.com', 'Cj', 'No', 'Ma', 'Region III (Central Luzon)', 'Bataan', 'City Of Balanga (Capital)', 'Malabia'),
('A26-0004', 'cjhanmao@gmail.com', 'Cj ', 'Nio', 'Matien', 'Region II (Cagayan Valley)', 'Isabela', 'Gamu', 'Pintor'),
('A26-0005', 'asdadaf@gmail.com', 'Sd', 'Dada', 'Dasdd', NULL, NULL, NULL, NULL),
('A26-0006', 'ahdiabdibavd@gmail.com', 'Asdad', 'Adada', 'Adadada', NULL, NULL, NULL, NULL),
('SUPER001', 'jamesmatthewalmonte45@gmail.com', 'Super', 'Nomo', 'Admin', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `attempt_questions`
--

CREATE TABLE `attempt_questions` (
  `attempt_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `blocks`
--

CREATE TABLE `blocks` (
  `block_id` int(11) NOT NULL,
  `program_id` int(11) NOT NULL,
  `block_name` varchar(50) NOT NULL,
  `capacity` int(11) DEFAULT 40,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `blocks`
--

INSERT INTO `blocks` (`block_id`, `program_id`, `block_name`, `capacity`, `is_active`) VALUES
(29, 8, '2A', 6, 0),
(30, 13, '1A', 40, 1),
(31, 14, '1A', 40, 1),
(32, 16, '1A', 40, 1),
(33, 17, '2A', 50, 1);

-- --------------------------------------------------------

--
-- Table structure for table `classes`
--

CREATE TABLE `classes` (
  `class_code` varchar(20) NOT NULL,
  `course_code` varchar(20) NOT NULL,
  `block_id` int(11) NOT NULL,
  `teacher_id` varchar(10) DEFAULT NULL,
  `semester` varchar(20) DEFAULT NULL,
  `academic_year` varchar(20) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `classes`
--

INSERT INTO `classes` (`class_code`, `course_code`, `block_id`, `teacher_id`, `semester`, `academic_year`, `is_active`) VALUES
('#101', 'CC1203', 33, 'T26-0003', NULL, NULL, 1),
('#102', 'COED1Q', 33, 'T26-0001', NULL, NULL, 1),
('#103', 'IT-2211', 30, 'T26-0005', NULL, NULL, 1),
('#104', 'IT-2206', 30, 'T26-0006', NULL, NULL, 1),
('#105', 'IT-2211', 31, 'T26-0007', NULL, NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `colleges`
--

CREATE TABLE `colleges` (
  `college_id` int(11) NOT NULL,
  `college_name` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `colleges`
--

INSERT INTO `colleges` (`college_id`, `college_name`, `description`, `is_active`) VALUES
(10, 'CCS', 'College of Computing Studies', 1),
(11, 'COED', 'College of Education', 1);

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `course_code` varchar(20) NOT NULL,
  `course_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `college_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`course_code`, `course_name`, `description`, `is_active`, `college_id`) VALUES
('CC-1100', 'Introduction to Computing', 'The course covers key topics such as computer hardware and software, data representation, operating systems, networking basics, and an overview of programming concepts. Students are introduced to problem-solving methodologies, algorithmic thinking, and basic coding structures to develop logical reasoning skills.\r\n\r\nAdditionally, the course examines the ethical, social, and professional issues related to computing, including data privacy, cybersecurity, and responsible use of technology. Through a combination of lectures, hands-on activities, and practical exercises, students gain essential digital literacy skills necessary for academic and professional success in the field of computing.', 1, 10),
('CC1203', 'Introduction to Education', 'Provide introduction in teaching', 1, 11),
('COED1Q', 'COED SUBJECT TEST', 'TEST SUBJECT', 1, 11),
('IT-2206', 'Database Management System', 'This course provides a comprehensive study of the principles, concepts, and technologies used in managing and organizing data within database systems. It introduces students to data models, relational database theory, normalization, and database design methodologies. Emphasis is placed on the practical use of Structured Query Language (SQL) for creating, querying, updating, and managing databases.', 1, 10),
('IT-2208', 'Quantitative Methods', 'This course introduces the fundamental principles and techniques of quantitative analysis used in decision-making across various disciplines. It focuses on the application of mathematical, statistical, and analytical methods to interpret data, solve problems, and support evidence-based conclusions.\r\n\r\nStudents will study topics such as data collection and presentation, measures of central tendency and variability, probability concepts, correlation and regression analysis, and basic inferential statistics. Emphasis is placed on the practical application of quantitative tools using real-world datasets to improve critical thinking and analytical skills.', 1, 10),
('IT-2211', 'Integrative Programming and Technologies 2', 'This course focuses on advanced web development using JavaScript and related technologies for building dynamic, interactive, and data-driven web applications. It extends foundational programming concepts by emphasizing client-side scripting, asynchronous programming, and integration with web APIs and backend services.\r\nStudents will develop proficiency in modern JavaScript features, DOM manipulation, event handling, and API consumption (e.g., RESTful services). The course also introduces practical integration of front-end frameworks, JSON-based data handling, and real-time web functionalities. Through hands-on projects, learners will design and implement responsive, efficient, and user-centered web applications that demonstrate effective integration of programming logic and web technologies.', 1, 10),
('ME 1', 'Mechanical Engineering', 'This course provides an introduction to the field of mechanical engineering, including the profession\'s history, scope, and areas of specialization. It covers fundamental engineering concepts, problem-solving techniques, engineering ethics, safety practices, and the role of mechanical engineers in industry and society. Students are introduced to basic engineering calculations, technical communication, design processes, and emerging technologies in mechanical engineering. The course also familiarizes students with laboratory practices, engineering standards, and career opportunities in the profession.', 1, 10);

-- --------------------------------------------------------

--
-- Table structure for table `enrollments`
--

CREATE TABLE `enrollments` (
  `enrollment_id` int(11) NOT NULL,
  `student_id` varchar(10) NOT NULL,
  `class_code` varchar(20) NOT NULL,
  `enrolled_at` timestamp NULL DEFAULT current_timestamp(),
  `status` enum('active','dropped','completed') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `enrollments`
--

INSERT INTO `enrollments` (`enrollment_id`, `student_id`, `class_code`, `enrolled_at`, `status`) VALUES
(124, 'S26-0006', '#101', '2026-07-11 05:33:02', 'active'),
(125, 'S26-0006', '#102', '2026-07-11 07:20:07', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `exams`
--

CREATE TABLE `exams` (
  `exam_id` int(11) NOT NULL,
  `class_code` varchar(20) NOT NULL,
  `title` varchar(200) NOT NULL,
  `duration_minutes` int(11) NOT NULL,
  `pass_percentage` int(11) DEFAULT 50,
  `is_active` tinyint(1) NOT NULL DEFAULT 0,
  `created_by` varchar(10) DEFAULT NULL,
  `date_time` datetime DEFAULT NULL,
  `archived` tinyint(1) DEFAULT 0,
  `question_limit` int(11) DEFAULT 50
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `exam_attempts`
--

CREATE TABLE `exam_attempts` (
  `attempt_id` int(11) NOT NULL,
  `student_id` varchar(10) DEFAULT NULL,
  `exam_id` int(11) DEFAULT NULL,
  `start_time` timestamp NULL DEFAULT current_timestamp(),
  `end_time` datetime DEFAULT NULL,
  `status` enum('in-progress','finished','timed-out','blocked') DEFAULT 'in-progress',
  `score` float DEFAULT 0,
  `tab_switches` int(11) DEFAULT 0,
  `current_q_index` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `exam_questions`
--

CREATE TABLE `exam_questions` (
  `exam_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `order_number` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `options`
--

CREATE TABLE `options` (
  `option_id` int(11) NOT NULL,
  `question_id` int(11) DEFAULT NULL,
  `option_text` text NOT NULL,
  `is_correct` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `otp_table`
--

CREATE TABLE `otp_table` (
  `otp_id` int(11) NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `otp_code` varchar(6) NOT NULL,
  `expires_at` datetime NOT NULL,
  `is_used` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `otp_table`
--

INSERT INTO `otp_table` (`otp_id`, `user_id`, `otp_code`, `expires_at`, `is_used`, `created_at`) VALUES
(20, 'A26-0000', '241209', '2026-04-26 00:35:26', 1, '2026-04-25 16:25:26'),
(21, 'A26-0000', '609267', '2026-04-26 21:38:01', 0, '2026-04-26 13:28:00'),
(22, 'A26-0000', '136986', '2026-04-26 21:38:42', 0, '2026-04-26 13:28:42'),
(23, 'A26-0000', '195118', '2026-04-26 21:39:11', 0, '2026-04-26 13:29:10'),
(24, 'A26-0000', '330738', '2026-04-26 21:39:20', 0, '2026-04-26 13:29:20'),
(25, 'A26-0000', '471887', '2026-04-26 21:40:32', 1, '2026-04-26 13:30:32'),
(26, 'A26-0000', '481935', '2026-04-26 23:29:11', 0, '2026-04-26 15:19:10'),
(27, 'A26-0000', '691959', '2026-04-26 23:30:36', 1, '2026-04-26 15:20:36'),
(28, 'A26-0000', '160417', '2026-04-26 23:34:37', 0, '2026-04-26 15:24:36'),
(29, 'A26-0000', '778881', '2026-04-26 23:34:42', 0, '2026-04-26 15:24:41'),
(30, 'A26-0000', '223184', '2026-04-26 23:34:48', 1, '2026-04-26 15:24:47'),
(31, 'A26-0000', '618859', '2026-04-28 23:47:32', 0, '2026-04-28 15:37:31'),
(32, 'A26-0000', '309406', '2026-04-28 23:47:43', 0, '2026-04-28 15:37:43'),
(33, 'A26-0000', '870265', '2026-04-28 23:49:26', 0, '2026-04-28 15:39:26'),
(34, 'A26-0000', '123350', '2026-04-28 23:49:31', 0, '2026-04-28 15:39:31'),
(35, 'A26-0000', '288303', '2026-04-28 23:49:42', 0, '2026-04-28 15:39:41'),
(51, 'A26-0000', '787604', '2026-04-29 01:52:41', 0, '2026-04-28 17:42:41'),
(52, 'A26-0000', '656707', '2026-04-29 01:53:09', 0, '2026-04-28 17:43:09'),
(53, 'A26-0000', '195894', '2026-04-29 01:53:42', 0, '2026-04-28 17:43:41'),
(54, 'A26-0000', '949168', '2026-04-29 01:57:03', 0, '2026-04-28 17:47:03'),
(55, 'A26-0000', '742166', '2026-04-29 01:57:14', 1, '2026-04-28 17:47:13'),
(66, 'A26-0000', '775406', '2026-04-29 20:30:33', 0, '2026-04-29 12:20:33'),
(67, 'A26-0000', '286809', '2026-04-29 20:31:30', 0, '2026-04-29 12:21:30'),
(68, 'A26-0000', '392363', '2026-04-29 20:55:49', 0, '2026-04-29 12:45:48'),
(69, 'A26-0000', '526553', '2026-04-29 20:55:58', 0, '2026-04-29 12:45:57'),
(70, 'A26-0000', '913461', '2026-04-29 20:56:04', 0, '2026-04-29 12:46:04'),
(83, 'A26-0000', '871548', '2026-04-29 21:30:19', 0, '2026-04-29 13:20:18'),
(84, 'A26-0000', '302272', '2026-04-29 21:31:35', 0, '2026-04-29 13:21:34'),
(85, 'A26-0000', '836052', '2026-04-29 21:34:00', 0, '2026-04-29 13:24:00'),
(86, 'A26-0000', '361065', '2026-04-29 21:34:19', 1, '2026-04-29 13:24:19'),
(87, 'A26-0000', '476274', '2026-04-29 21:37:14', 0, '2026-04-29 13:27:13'),
(89, 'A26-0000', '359521', '2026-05-01 22:10:24', 0, '2026-05-01 14:00:23'),
(90, 'A26-0000', '405462', '2026-05-02 00:29:29', 1, '2026-05-01 16:19:28'),
(91, 'A26-0000', '389707', '2026-05-03 23:35:37', 0, '2026-05-03 15:25:37'),
(92, 'A26-0000', '182098', '2026-05-03 23:46:39', 1, '2026-05-03 15:36:39');

-- --------------------------------------------------------

--
-- Table structure for table `pending_users`
--

CREATE TABLE `pending_users` (
  `pending_id` int(11) NOT NULL,
  `email` varchar(200) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('teacher','student') NOT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `middlename` varchar(50) DEFAULT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  `block_id` int(11) DEFAULT NULL,
  `region` varchar(100) DEFAULT NULL,
  `province` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `barangay` varchar(100) DEFAULT NULL,
  `is_otp_verified` tinyint(1) DEFAULT 0,
  `document_path` varchar(255) DEFAULT NULL,
  `verification_status` enum('pending_upload','pending_approval','rejected') DEFAULT 'pending_upload',
  `admin_notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `otp_code` varchar(6) DEFAULT NULL,
  `otp_expires_at` datetime DEFAULT NULL,
  `otp_count` int(11) DEFAULT 1,
  `last_otp_sent` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `programs`
--

CREATE TABLE `programs` (
  `program_id` int(11) NOT NULL,
  `program_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `college_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `programs`
--

INSERT INTO `programs` (`program_id`, `program_name`, `description`, `is_active`, `college_id`) VALUES
(5, 'BSA', 'Bachelor of Science in Accountancy', 0, NULL),
(6, 'BSCS-DS', 'Bachelor of Science in Computer Science with Specialization in Data Science', 0, NULL),
(7, 'BSE', 'Bachelor of Science in Entrepreneurship', 0, NULL),
(8, 'BSME', 'Bachelor of Science in Mechanical Engineering', 0, NULL),
(9, 'BSPsy', 'Bachelor of Science in Psychology', 0, NULL),
(10, 'BAPsy', 'Bachelor of Arts in Psychology', 0, NULL),
(11, 'BAC', 'Bachelor of Arts in Communications', 0, NULL),
(12, 'BSAIS', 'Bachelor of Science in Accounting Information System', 0, NULL),
(13, 'BSIT', '', 1, 10),
(14, 'BSCS', 'Computer Science', 1, 10),
(16, 'BSSSS', 'ASFDASFS', 1, 10),
(17, 'BSED', 'Bachelor of Science in Education', 1, 11);

-- --------------------------------------------------------

--
-- Table structure for table `questions`
--

CREATE TABLE `questions` (
  `question_id` int(11) NOT NULL,
  `question_text` text NOT NULL,
  `question_type` enum('multiple_choice','true_false','identification','essay') DEFAULT NULL,
  `difficulty` enum('easy','medium','hard') DEFAULT NULL,
  `course_code` varchar(20) DEFAULT NULL,
  `is_isolated` tinyint(1) DEFAULT 0,
  `teacher_id` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `student_id` varchar(10) NOT NULL,
  `email` varchar(200) NOT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `middlename` varchar(50) DEFAULT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  `block_id` int(11) DEFAULT NULL,
  `region` varchar(50) DEFAULT NULL,
  `province` varchar(50) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `barangay` varchar(50) DEFAULT NULL,
  `college` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`student_id`, `email`, `firstname`, `middlename`, `lastname`, `block_id`, `region`, `province`, `city`, `barangay`, `college`) VALUES
('S26-0001', 'arnzo@gmail.com', 'Cj Han', 'Nomo', 'Matienzo', NULL, 'Region I (Ilocos Region)', 'La Union', 'San Juan', 'Casilagan', NULL),
('S26-0002', 'adaa@gmail.com', 'sda', 'adas', 'adas', NULL, 'Region I (Ilocos Region)', 'Ilocos Sur', 'Quirino (Angkaki)', 'Cayus', NULL),
('S26-0003', 'jgutiza30@gmail.com', 'Joan ', 'Sidamon ', 'Gutiza', 30, 'Region III (Central Luzon)', 'Bataan', 'Hermosa', 'Judge Roman Cruz Sr. (Mandama)', NULL),
('S26-0004', 'oninnapiza4@gmail.com', 'Onin', '', 'Napiza', 32, 'Region I (Ilocos Region)', 'Ilocos Norte', 'Bacarra', 'Macupit', NULL),
('S26-0005', 'gutizaaudie1@gmail.com', 'Xzon', '', 'Guinto', 31, 'Region I (Ilocos Region)', 'Ilocos Norte', 'Adams', 'Adams (Pob.)', NULL),
('S26-0006', 'xzoneginto@gmail.com', 'Xzone', 'Nazarene', 'Ginto', 33, 'Region IV-A (CALABARZON)', 'Laguna', 'Nagcarlan', 'Maravilla', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `student_answers`
--

CREATE TABLE `student_answers` (
  `answer_id` int(11) NOT NULL,
  `attempt_id` int(11) DEFAULT NULL,
  `question_id` int(11) DEFAULT NULL,
  `submitted_answer` text DEFAULT NULL,
  `is_correct` tinyint(1) DEFAULT 0,
  `is_flagged` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sync_failures`
--

CREATE TABLE `sync_failures` (
  `id` int(11) NOT NULL,
  `target_module` varchar(20) NOT NULL,
  `payload_json` text NOT NULL,
  `reason` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `resolved` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sync_failures`
--

INSERT INTO `sync_failures` (`id`, `target_module`, `payload_json`, `reason`, `created_at`, `resolved`) VALUES
(2, 'attendance', '{\"username\": \"T26-0003\", \"password\": \"Admin@123\", \"full_name\": \"Cj No Maenzo\", \"role\": \"teacher\", \"email\": \"cjhano@gmail.com\"}', 'Unreachable: Expecting value: line 1 column 1 (char 0)', '2026-07-10 11:57:00', 1),
(3, 'attendance', '{\"username\": \"A26-0003\", \"password\": \"Admin@123\", \"full_name\": \"Cj No Ma\", \"role\": \"admin\", \"email\": \"ahahazo@gmail.com\"}', 'Unreachable: Expecting value: line 1 column 1 (char 0)', '2026-07-10 12:11:11', 1);

-- --------------------------------------------------------

--
-- Table structure for table `teachers`
--

CREATE TABLE `teachers` (
  `teacher_id` varchar(10) NOT NULL,
  `email` varchar(200) NOT NULL,
  `firstname` varchar(50) DEFAULT NULL,
  `middlename` varchar(50) DEFAULT NULL,
  `lastname` varchar(50) DEFAULT NULL,
  `region` varchar(50) DEFAULT NULL,
  `province` varchar(50) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `barangay` varchar(50) DEFAULT NULL,
  `college_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `teachers`
--

INSERT INTO `teachers` (`teacher_id`, `email`, `firstname`, `middlename`, `lastname`, `region`, `province`, `city`, `barangay`, `college_id`) VALUES
('T26-0001', 'cjhanenzo@gmail.com', 'Cj Han', 'Nomo', 'Matienzo', 'Region III (Central Luzon)', 'Bulacan', 'Doña Remedios Trinidad', 'Camachile', 11),
('T26-0002', 'cjhanmanzo@gmail.com', 'Cj', 'Nomo', 'Matienzo', 'Region III (Central Luzon)', 'Nueva Ecija', 'Llanera', 'Plaridel', NULL),
('T26-0003', 'cjhano@gmail.com', 'Cj', 'No', 'Maenzo', 'Region II (Cagayan Valley)', 'Cagayan', 'Gonzaga', 'Isca', NULL),
('T26-0004', 'johnandreisidamongutiza@gmail.com', 'John Andrei', 'Sidamon ', 'Napiza', 'Region XII (SOCCSKSARGEN)', 'Cotabato (North Cotabato)', 'President Roxas', 'La Esperanza', 10),
('T26-0005', 'johnandreisidamongutizaa@gmail.com', 'John Andrei', '', 'gutiza', 'Cordillera Administrative Region (CAR)', 'Abra', 'Manabo', 'San Ramon West', NULL),
('T26-0006', 'jgutiza301@gmail.com', 'John Andrei', '', 'gutizas', 'National Capital Region (NCR)', 'Ncr, City Of Manila, First District', 'San Nicolas', 'Barangay 282', NULL),
('T26-0007', 'oninnapiza41@gmail.com', 'Onin', '', 'napizas', 'Cordillera Administrative Region (CAR)', 'Abra', 'Pidigan', 'Sulbec', 10);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` varchar(10) NOT NULL,
  `email` varchar(200) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `role` enum('super_admin','admin','teacher','student') DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1,
  `otp_count` int(11) DEFAULT 0,
  `last_otp_sent` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `email`, `password`, `role`, `is_verified`, `created_at`, `is_active`, `otp_count`, `last_otp_sent`) VALUES
('A26-0000', 'justindion180@gmail.com', 'scrypt:32768:8:1$U6dSaNNxSJAP6jNi$9af5ecf8f5d6c73f8a6f923e3036ab9d7515f6f4f13246f7085402b3d56d83eca2a3f9171e15154030381b2cbc8292d90b1d94444dbd8a05ba6e3739fe0c38d7', 'super_admin', 1, '2026-03-23 06:24:05', 1, 2, '2026-05-03 15:36:39'),
('A26-0001', 'gonzalvo.tyrael@gmail.com', 'scrypt:32768:8:1$fWpnuZK9VixIhAp3$8de467209ea970f8e748e6267afd312e1a2344897e825c8ac743ca474cbc441faec3cec05366db536aabf26d00576e799dd16e3373c9bf6270fd306a5fa25608', 'admin', 1, '2026-07-02 14:24:08', 1, 0, NULL),
('A26-0002', 'cjmatienzo@gmail.com', 'scrypt:32768:8:1$HrGixnFdfcxfwgMk$d0837b2726066d757371a6990d30d287b6ba1f4d2fa78462138109da5d0c97ac618a1ef7e073b7a93c805713c84aa448384dd780c40585830b5d89d2d5661671', 'admin', 1, '2026-07-08 12:28:53', 1, 0, NULL),
('A26-0003', 'ahahazo@gmail.com', 'scrypt:32768:8:1$durJlxkuM8kAICfr$63c8c3c218382faf766376aae9cd2511662a08505699d7cda5f67a52dd8a9411966b25d94ee7f6bc2f15d8115511d2f047f17643f150bf501e3fb54ded9584b0', 'admin', 1, '2026-07-10 04:11:07', 1, 0, NULL),
('A26-0004', 'cjhanmao@gmail.com', 'scrypt:32768:8:1$CC6T3OvkXhvcCJUB$52a90d64313d11a2cda7b2d6451a93fe42f98b46393703922fa76d4c5b25285466d9fc87f21c7908dd14f0e3d1dbaca610a616bd01fe1df53b2e66333d106fed', 'admin', 1, '2026-07-10 08:02:11', 1, 0, NULL),
('A26-0005', 'asdadaf@gmail.com', 'scrypt:32768:8:1$NaBbK0JvVIyqsCCE$4276f4edae9922b00eae70d8da431368a8bb6b6bd374c00988febc4edaf6b79cb9c34ded607692414ddd208547a8df497efc7793b0000c6956844c8640c0e161', 'admin', 1, '2026-07-10 13:50:30', 1, 0, NULL),
('A26-0006', 'ahdiabdibavd@gmail.com', 'scrypt:32768:8:1$Gr1MpdQppujrVCuX$8235d4adc94cc44f7968cd25a6bf2d2d5aecb2249b8a42e39bda100eafd4e003d0d26220cc740bde914487f93e54bfd5c3bc5dc8a00a4389c80460b07243a43d', 'admin', 1, '2026-07-10 13:51:23', 1, 0, NULL),
('S26-0001', 'arnzo@gmail.com', 'scrypt:32768:8:1$JhSG8mBBhKsuaRNA$1390134f35dc8f4f759dd62d16a0f85926f5a5edbb00c7175466da0de150f51e2ee71edb0e2157ccce329e0bc98fffa891dee1ffb296adb1321f9645a5072215', 'student', 1, '2026-07-09 14:03:58', 1, 0, NULL),
('S26-0002', 'adaa@gmail.com', 'scrypt:32768:8:1$DbB7FuXwGxIVaaQy$9fa5e56c8f12f4f51cbded0380d47ee7c5db02344970efd10f5145eb8538a35538162c44683741f9d4aa9a0babd11ccccc3baa08be7d8fac0cb3ebdb63d7c9a1', 'student', 1, '2026-07-09 14:07:41', 1, 0, NULL),
('S26-0003', 'jgutiza30@gmail.com', 'scrypt:32768:8:1$EcuMSRQvdRMEfcgE$799253ec373e60c1f91e3150d949041c255eaf70f4b45112db87e12ca403f49e6825d96c768db33d1ceeac8c08cda454d117bb9927b095fbf072bba027d33f78', 'student', 1, '2026-07-10 18:51:20', 1, 0, NULL),
('S26-0004', 'oninnapiza4@gmail.com', 'scrypt:32768:8:1$JyaGKt1uTQyjAj8G$3160d5092c2f6c0089fe7255f9c6fe5b65234af56ed66abb7ffa4792d8142d07630be50c79ffa01b353267e7525425b7697890d51cc6ded447d82b8c5e17421d', 'student', 1, '2026-07-10 20:13:45', 1, 0, NULL),
('S26-0005', 'gutizaaudie1@gmail.com', 'scrypt:32768:8:1$UbYI7KqJII7yKBfv$e6dbe502d251149971479b83c95248454c04888866308096f3c84127e0d5e6815311cfd38b0f65db09630ca8f3b05d419b86961cfc43757b4e45480406f68597', 'student', 1, '2026-07-10 20:31:32', 1, 0, NULL),
('S26-0006', 'xzoneginto@gmail.com', 'scrypt:32768:8:1$LWv9dsmne9jB0ss7$dd27266272d379bd187d95a0c89e83e661b4fcf1f4746714800e4d5312407fe13858845c48a4ffad2255af1edf13d068f77951f87a4dc7da33220a6ecb56c9ef', 'student', 1, '2026-07-11 04:18:38', 1, 0, NULL),
('SUPER001', 'jamesmatthewalmonte45@gmail.com', 'scrypt:32768:8:1$4j8bqUUcuAoYquDU$633b6616fa3249e7c6042d64c54d677f13d55f30d5025c70a104c96cddc1ce490828fe065bed71320b8ed9d3a08d429b85c5050209b37ae104d9b381a23b41be', 'super_admin', 1, '2026-07-06 13:40:42', 1, 0, NULL),
('T26-0001', 'cjhanenzo@gmail.com', 'scrypt:32768:8:1$vk1bWhlpirUir1IC$5104359897a0854f2a9737fab1e8e04b618a46504fb33e5ccd6d74dd4224cfb3f2214e37993ac0248d9aeacb3ce3ac6fdb3c84a43c23be5b753b5a102d457bf6', 'teacher', 1, '2026-07-10 01:26:38', 1, 0, NULL),
('T26-0002', 'cjhanmanzo@gmail.com', 'scrypt:32768:8:1$OfIaNyVQroILnDTp$40aee964512d281b3427ed7429aef8ce8b8583a2e682aaeac18773e75f90ba08973545dd5457127ca789795990e6375869ba02e81988ec3931666c895a8f4e89', 'teacher', 1, '2026-07-10 01:35:22', 1, 0, NULL),
('T26-0003', 'cjhano@gmail.com', 'scrypt:32768:8:1$TlsYid82pt2hfIjh$b5bb07da8fa94dc71f3d3e0822c8ab5711413fa926c52badec859ab2c93bc0f0a8f5b270fd732cfb98dd303e5f56e1d53fab1a3c4f99c15ab1c3eb746e26af67', 'teacher', 1, '2026-07-10 03:56:56', 1, 0, NULL),
('T26-0004', 'johnandreisidamongutiza@gmail.com', 'scrypt:32768:8:1$jvedwdjGH5E6xRc2$1a961c2c10d5e998af97264a75ca27d56ea1c976063764a319d6832f4c0411b0645b131c6e80ea3e3e6b233193f8edb5e93ecefcdda20f284bd8d5e52edac044', 'teacher', 1, '2026-07-11 09:17:54', 1, 0, NULL),
('T26-0005', 'johnandreisidamongutizaa@gmail.com', 'scrypt:32768:8:1$RMEAvsyEUwY8x6mK$b39d7a75144478b77190238a80499e1127d62cd62873180977e6b87a3b6c2dd5b2ee83707b76dfe27ae5ec23aad10e9da42704020653de66ec0b6a87160f949b', 'teacher', 1, '2026-07-11 09:20:44', 1, 0, NULL),
('T26-0006', 'jgutiza301@gmail.com', 'scrypt:32768:8:1$HSxx7MrydnnwJ8de$2e9e23be22da9692eb4b73db5aa17482b84d6b0a4186d74d20c90a8b508e56e7c6cc97d2aad7867f848d419fdffbf3af9debca5ce615fe078e2d69c93e4c62a8', 'teacher', 1, '2026-07-11 09:22:15', 1, 0, NULL),
('T26-0007', 'oninnapiza41@gmail.com', 'scrypt:32768:8:1$8KtOUcUNXnxfI2si$b080e6228e7b4cb760a56906f1b537adb9f1ab80fcfcc8f28c1be31bf136db660b1df80075c1b25840ef7d4abbec7ca262511b083a75e7f1817dcca627241699', 'teacher', 1, '2026-07-11 09:23:38', 1, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `violation_logs`
--

CREATE TABLE `violation_logs` (
  `log_id` int(11) NOT NULL,
  `attempt_id` int(11) DEFAULT NULL,
  `violation_type` varchar(100) DEFAULT NULL,
  `violation_time` datetime DEFAULT current_timestamp(),
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`admin_id`),
  ADD KEY `email` (`email`);

--
-- Indexes for table `attempt_questions`
--
ALTER TABLE `attempt_questions`
  ADD PRIMARY KEY (`attempt_id`,`question_id`),
  ADD KEY `fk_aq_question` (`question_id`);

--
-- Indexes for table `blocks`
--
ALTER TABLE `blocks`
  ADD PRIMARY KEY (`block_id`),
  ADD UNIQUE KEY `unique_block_per_program` (`program_id`,`block_name`);

--
-- Indexes for table `classes`
--
ALTER TABLE `classes`
  ADD PRIMARY KEY (`class_code`),
  ADD KEY `fk_class_subject` (`course_code`),
  ADD KEY `fk_class_block` (`block_id`),
  ADD KEY `fk_class_teacher` (`teacher_id`);

--
-- Indexes for table `colleges`
--
ALTER TABLE `colleges`
  ADD PRIMARY KEY (`college_id`),
  ADD UNIQUE KEY `unique_college` (`college_name`);

--
-- Indexes for table `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`course_code`),
  ADD UNIQUE KEY `unique_course` (`course_code`,`course_name`),
  ADD KEY `fk_course_college` (`college_id`);

--
-- Indexes for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD PRIMARY KEY (`enrollment_id`),
  ADD UNIQUE KEY `unique_student_per_class` (`student_id`,`class_code`),
  ADD KEY `fk_enrollment_class` (`class_code`);

--
-- Indexes for table `exams`
--
ALTER TABLE `exams`
  ADD PRIMARY KEY (`exam_id`),
  ADD KEY `fk_exam_creator` (`created_by`),
  ADD KEY `fk_exam_class` (`class_code`);

--
-- Indexes for table `exam_attempts`
--
ALTER TABLE `exam_attempts`
  ADD PRIMARY KEY (`attempt_id`),
  ADD KEY `fk_attempt_student` (`student_id`),
  ADD KEY `fk_attempt_exam` (`exam_id`);

--
-- Indexes for table `exam_questions`
--
ALTER TABLE `exam_questions`
  ADD PRIMARY KEY (`exam_id`,`question_id`),
  ADD KEY `question_id` (`question_id`);

--
-- Indexes for table `options`
--
ALTER TABLE `options`
  ADD PRIMARY KEY (`option_id`),
  ADD KEY `fk_option_question` (`question_id`);

--
-- Indexes for table `otp_table`
--
ALTER TABLE `otp_table`
  ADD PRIMARY KEY (`otp_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_user_otp` (`user_id`,`otp_code`),
  ADD KEY `idx_user_active` (`user_id`,`is_used`);

--
-- Indexes for table `pending_users`
--
ALTER TABLE `pending_users`
  ADD PRIMARY KEY (`pending_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `programs`
--
ALTER TABLE `programs`
  ADD PRIMARY KEY (`program_id`),
  ADD UNIQUE KEY `program_name` (`program_name`),
  ADD KEY `fk_program_college` (`college_id`);

--
-- Indexes for table `questions`
--
ALTER TABLE `questions`
  ADD PRIMARY KEY (`question_id`),
  ADD KEY `fk_question_subject` (`course_code`),
  ADD KEY `fk_question_teacher` (`teacher_id`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`student_id`),
  ADD KEY `email` (`email`),
  ADD KEY `fk_student_block` (`block_id`);

--
-- Indexes for table `student_answers`
--
ALTER TABLE `student_answers`
  ADD PRIMARY KEY (`answer_id`),
  ADD UNIQUE KEY `unique_answer` (`attempt_id`,`question_id`),
  ADD KEY `fk_answer_question` (`question_id`);

--
-- Indexes for table `sync_failures`
--
ALTER TABLE `sync_failures`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `teachers`
--
ALTER TABLE `teachers`
  ADD PRIMARY KEY (`teacher_id`),
  ADD KEY `email` (`email`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `email_2` (`email`);

--
-- Indexes for table `violation_logs`
--
ALTER TABLE `violation_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `attempt_id` (`attempt_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `blocks`
--
ALTER TABLE `blocks`
  MODIFY `block_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `colleges`
--
ALTER TABLE `colleges`
  MODIFY `college_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `enrollments`
--
ALTER TABLE `enrollments`
  MODIFY `enrollment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=126;

--
-- AUTO_INCREMENT for table `exams`
--
ALTER TABLE `exams`
  MODIFY `exam_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=99;

--
-- AUTO_INCREMENT for table `exam_attempts`
--
ALTER TABLE `exam_attempts`
  MODIFY `attempt_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=241;

--
-- AUTO_INCREMENT for table `options`
--
ALTER TABLE `options`
  MODIFY `option_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7115;

--
-- AUTO_INCREMENT for table `otp_table`
--
ALTER TABLE `otp_table`
  MODIFY `otp_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- AUTO_INCREMENT for table `pending_users`
--
ALTER TABLE `pending_users`
  MODIFY `pending_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `programs`
--
ALTER TABLE `programs`
  MODIFY `program_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `questions`
--
ALTER TABLE `questions`
  MODIFY `question_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2572;

--
-- AUTO_INCREMENT for table `student_answers`
--
ALTER TABLE `student_answers`
  MODIFY `answer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4484;

--
-- AUTO_INCREMENT for table `sync_failures`
--
ALTER TABLE `sync_failures`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `violation_logs`
--
ALTER TABLE `violation_logs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=653;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admins`
--
ALTER TABLE `admins`
  ADD CONSTRAINT `fk_admin_email` FOREIGN KEY (`email`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_admin_id` FOREIGN KEY (`admin_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `attempt_questions`
--
ALTER TABLE `attempt_questions`
  ADD CONSTRAINT `fk_aq_attempt` FOREIGN KEY (`attempt_id`) REFERENCES `exam_attempts` (`attempt_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_aq_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE;

--
-- Constraints for table `blocks`
--
ALTER TABLE `blocks`
  ADD CONSTRAINT `fk_block_program` FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`) ON DELETE CASCADE;

--
-- Constraints for table `classes`
--
ALTER TABLE `classes`
  ADD CONSTRAINT `fk_class_block` FOREIGN KEY (`block_id`) REFERENCES `blocks` (`block_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_class_subject` FOREIGN KEY (`course_code`) REFERENCES `courses` (`course_code`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_class_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`teacher_id`) ON DELETE SET NULL;

--
-- Constraints for table `courses`
--
ALTER TABLE `courses`
  ADD CONSTRAINT `fk_course_college` FOREIGN KEY (`college_id`) REFERENCES `colleges` (`college_id`) ON DELETE SET NULL;

--
-- Constraints for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD CONSTRAINT `fk_enrollment_class` FOREIGN KEY (`class_code`) REFERENCES `classes` (`class_code`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_enrollment_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `exams`
--
ALTER TABLE `exams`
  ADD CONSTRAINT `fk_exam_class` FOREIGN KEY (`class_code`) REFERENCES `classes` (`class_code`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_exam_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `exam_attempts`
--
ALTER TABLE `exam_attempts`
  ADD CONSTRAINT `fk_attempt_exam` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_attempt_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE;

--
-- Constraints for table `exam_questions`
--
ALTER TABLE `exam_questions`
  ADD CONSTRAINT `exam_questions_ibfk_1` FOREIGN KEY (`exam_id`) REFERENCES `exams` (`exam_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `exam_questions_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE;

--
-- Constraints for table `options`
--
ALTER TABLE `options`
  ADD CONSTRAINT `fk_option_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE;

--
-- Constraints for table `otp_table`
--
ALTER TABLE `otp_table`
  ADD CONSTRAINT `otp_table_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `programs`
--
ALTER TABLE `programs`
  ADD CONSTRAINT `fk_program_college` FOREIGN KEY (`college_id`) REFERENCES `colleges` (`college_id`) ON DELETE SET NULL;

--
-- Constraints for table `questions`
--
ALTER TABLE `questions`
  ADD CONSTRAINT `fk_question_subject` FOREIGN KEY (`course_code`) REFERENCES `courses` (`course_code`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_question_teacher` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`teacher_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `fk_student_block` FOREIGN KEY (`block_id`) REFERENCES `blocks` (`block_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_student_email` FOREIGN KEY (`email`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_student_id` FOREIGN KEY (`student_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `student_answers`
--
ALTER TABLE `student_answers`
  ADD CONSTRAINT `fk_answer_attempt` FOREIGN KEY (`attempt_id`) REFERENCES `exam_attempts` (`attempt_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_answer_question` FOREIGN KEY (`question_id`) REFERENCES `questions` (`question_id`) ON DELETE CASCADE;

--
-- Constraints for table `teachers`
--
ALTER TABLE `teachers`
  ADD CONSTRAINT `fk_teacher_email` FOREIGN KEY (`email`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_teacher_id` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `violation_logs`
--
ALTER TABLE `violation_logs`
  ADD CONSTRAINT `violation_logs_ibfk_1` FOREIGN KEY (`attempt_id`) REFERENCES `exam_attempts` (`attempt_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
