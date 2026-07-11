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
-- Database: `db_exam`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `admin_id` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `firstname` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `middlename` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `lastname` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `region` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `province` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `city` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `barangay` varchar(200) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`admin_id`, `email`, `firstname`, `middlename`, `lastname`, `region`, `province`, `city`, `barangay`) VALUES
('A26-0000', 'justindion180@gmail.com', 'Justin Dion', 'Bibon', 'Salaveria', 'Region IV-A (CALABARZON)', 'Laguna', 'Santa Cruz (Capital)', 'Labuin'),
('A26-0001', 'gonzalvo.tyrael@gmail.com', 'Tyrael', '', 'Gonzalvo', 'Autonomous Region in Muslim Mindanao (ARMM)', 'Maguindanao', 'Mangudadatu', 'Tenok'),
('SUPER001', 'jamesmatthewalmonte45@gmail.com', 'Super', 'Nomo', 'Admin', NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `attempt_questions`
--

CREATE TABLE `attempt_questions` (
  `attempt_id` int NOT NULL,
  `question_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attempt_questions`
--

INSERT INTO `attempt_questions` (`attempt_id`, `question_id`) VALUES
(243, 2572),
(243, 2573),
(243, 2574),
(243, 2575),
(243, 2576),
(243, 2577),
(243, 2578),
(243, 2579),
(243, 2580),
(243, 2581),
(243, 2582),
(243, 2583),
(243, 2584),
(243, 2585),
(243, 2586),
(243, 2587),
(243, 2588),
(243, 2589),
(243, 2590),
(243, 2591);

-- --------------------------------------------------------

--
-- Table structure for table `blocks`
--

CREATE TABLE `blocks` (
  `block_id` int NOT NULL,
  `program_id` int NOT NULL,
  `block_name` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `capacity` int DEFAULT '40',
  `is_active` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `blocks`
--

INSERT INTO `blocks` (`block_id`, `program_id`, `block_name`, `capacity`, `is_active`) VALUES
(11, 1, '2A', 4, 0),
(26, 1, '2B', 3, 0),
(27, 1, '2C', 4, 0),
(28, 1, '2D', 2, 0),
(29, 8, '2A', 6, 0),
(30, 1, '1A', 40, 1);

-- --------------------------------------------------------

--
-- Table structure for table `classes`
--

CREATE TABLE `classes` (
  `class_code` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `course_code` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `block_id` int NOT NULL,
  `teacher_id` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `semester` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `academic_year` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `classes`
--

INSERT INTO `classes` (`class_code`, `course_code`, `block_id`, `teacher_id`, `semester`, `academic_year`, `is_active`) VALUES
('#101', 'CC-1100', 30, 'T26-0001', NULL, NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `colleges`
--

CREATE TABLE `colleges` (
  `college_id` int NOT NULL,
  `college_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `is_active` tinyint(1) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `colleges`
--

INSERT INTO `colleges` (`college_id`, `college_name`, `description`, `is_active`) VALUES
(10, 'CCS', 'College of Computing Studies\r\n', 1);

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `course_code` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `course_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `description` text COLLATE utf8mb4_general_ci,
  `is_active` tinyint(1) DEFAULT '1',
  `college_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`course_code`, `course_name`, `description`, `is_active`, `college_id`) VALUES
('CC-1100', 'Introduction to Computing', 'The course covers key topics such as computer hardware and software, data representation, operating systems, networking basics, and an overview of programming concepts. Students are introduced to problem-solving methodologies, algorithmic thinking, and basic coding structures to develop logical reasoning skills.\r\n\r\nAdditionally, the course examines the ethical, social, and professional issues related to computing, including data privacy, cybersecurity, and responsible use of technology. Through a combination of lectures, hands-on activities, and practical exercises, students gain essential digital literacy skills necessary for academic and professional success in the field of computing.', 1, 10),
('IT-2206', 'Database Management System', 'This course provides a comprehensive study of the principles, concepts, and technologies used in managing and organizing data within database systems. It introduces students to data models, relational database theory, normalization, and database design methodologies. Emphasis is placed on the practical use of Structured Query Language (SQL) for creating, querying, updating, and managing databases.', 1, 10),
('IT-2208', 'Quantitative Methods', 'This course introduces the fundamental principles and techniques of quantitative analysis used in decision-making across various disciplines. It focuses on the application of mathematical, statistical, and analytical methods to interpret data, solve problems, and support evidence-based conclusions.\r\n\r\nStudents will study topics such as data collection and presentation, measures of central tendency and variability, probability concepts, correlation and regression analysis, and basic inferential statistics. Emphasis is placed on the practical application of quantitative tools using real-world datasets to improve critical thinking and analytical skills.', 1, 10),
('IT-2211', 'Integrative Programming and Technologies 2', 'This course focuses on advanced web development using JavaScript and related technologies for building dynamic, interactive, and data-driven web applications. It extends foundational programming concepts by emphasizing client-side scripting, asynchronous programming, and integration with web APIs and backend services.\r\nStudents will develop proficiency in modern JavaScript features, DOM manipulation, event handling, and API consumption (e.g., RESTful services). The course also introduces practical integration of front-end frameworks, JSON-based data handling, and real-time web functionalities. Through hands-on projects, learners will design and implement responsive, efficient, and user-centered web applications that demonstrate effective integration of programming logic and web technologies.', 1, 10),
('ME 1', 'Mechanical Engineering', 'This course provides an introduction to the field of mechanical engineering, including the profession\'s history, scope, and areas of specialization. It covers fundamental engineering concepts, problem-solving techniques, engineering ethics, safety practices, and the role of mechanical engineers in industry and society. Students are introduced to basic engineering calculations, technical communication, design processes, and emerging technologies in mechanical engineering. The course also familiarizes students with laboratory practices, engineering standards, and career opportunities in the profession.', 1, 10);

-- --------------------------------------------------------

--
-- Table structure for table `enrollments`
--

CREATE TABLE `enrollments` (
  `enrollment_id` int NOT NULL,
  `student_id` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `class_code` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `enrolled_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` enum('active','dropped','completed') COLLATE utf8mb4_general_ci DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `enrollments`
--

INSERT INTO `enrollments` (`enrollment_id`, `student_id`, `class_code`, `enrolled_at`, `status`) VALUES
(124, 'S26-0001', '#101', '2026-07-08 14:41:25', 'active');

-- --------------------------------------------------------

--
-- Table structure for table `exams`
--

CREATE TABLE `exams` (
  `exam_id` int NOT NULL,
  `class_code` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `title` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `duration_minutes` int NOT NULL,
  `pass_percentage` int DEFAULT '50',
  `is_active` tinyint(1) NOT NULL DEFAULT '0',
  `created_by` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `date_time` datetime DEFAULT NULL,
  `archived` tinyint(1) DEFAULT '0',
  `question_limit` int DEFAULT '50',
  `allow_review` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `exams`
--

INSERT INTO `exams` (`exam_id`, `class_code`, `title`, `duration_minutes`, `pass_percentage`, `is_active`, `created_by`, `date_time`, `archived`, `question_limit`, `allow_review`) VALUES
(99, '#101', '190', 600, 50, 1, 'T26-0001', '2026-07-08 21:32:00', 0, 50, 1);

-- --------------------------------------------------------

--
-- Table structure for table `exam_attempts`
--

CREATE TABLE `exam_attempts` (
  `attempt_id` int NOT NULL,
  `student_id` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `exam_id` int DEFAULT NULL,
  `start_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `end_time` datetime DEFAULT NULL,
  `status` enum('in-progress','finished','timed-out','blocked') COLLATE utf8mb4_general_ci DEFAULT 'in-progress',
  `score` float DEFAULT '0',
  `tab_switches` int DEFAULT '0',
  `current_q_index` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `exam_attempts`
--

INSERT INTO `exam_attempts` (`attempt_id`, `student_id`, `exam_id`, `start_time`, `end_time`, `status`, `score`, `tab_switches`, `current_q_index`) VALUES
(243, 'S26-0001', 99, '2026-07-08 15:04:58', '2026-07-08 23:05:38', 'finished', 0, 0, 4);

-- --------------------------------------------------------

--
-- Table structure for table `exam_questions`
--

CREATE TABLE `exam_questions` (
  `exam_id` int NOT NULL,
  `question_id` int NOT NULL,
  `order_number` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `exam_questions`
--

INSERT INTO `exam_questions` (`exam_id`, `question_id`, `order_number`) VALUES
(99, 2572, 0),
(99, 2573, 0),
(99, 2574, 0),
(99, 2575, 0),
(99, 2576, 0),
(99, 2577, 0),
(99, 2578, 0),
(99, 2579, 0),
(99, 2580, 0),
(99, 2581, 0),
(99, 2582, 0),
(99, 2583, 0),
(99, 2584, 0),
(99, 2585, 0),
(99, 2586, 0),
(99, 2587, 0),
(99, 2588, 0),
(99, 2589, 0),
(99, 2590, 0),
(99, 2591, 0);

-- --------------------------------------------------------

--
-- Table structure for table `options`
--

CREATE TABLE `options` (
  `option_id` int NOT NULL,
  `question_id` int DEFAULT NULL,
  `option_text` text COLLATE utf8mb4_general_ci NOT NULL,
  `is_correct` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `options`
--

INSERT INTO `options` (`option_id`, `question_id`, `option_text`, `is_correct`) VALUES
(7115, 2572, 'True', 0),
(7116, 2572, 'False', 1),
(7117, 2573, 'True', 1),
(7118, 2573, 'False', 0),
(7119, 2574, 'True', 0),
(7120, 2574, 'False', 1),
(7121, 2575, 'True', 1),
(7122, 2575, 'False', 0),
(7123, 2576, 'True', 0),
(7124, 2576, 'False', 1),
(7125, 2577, 'True', 1),
(7126, 2577, 'False', 0),
(7127, 2578, 'True', 0),
(7128, 2578, 'False', 1),
(7129, 2579, 'True', 1),
(7130, 2579, 'False', 0),
(7131, 2580, 'True', 0),
(7132, 2580, 'False', 1),
(7133, 2581, 'True', 1),
(7134, 2581, 'False', 0),
(7135, 2582, 'Horizontal Integration', 1),
(7136, 2583, 'Spaghetti integration', 1),
(7137, 2584, 'Feasibility Analysis', 1),
(7138, 2585, 'Enterprise Application Integration', 1),
(7139, 2586, 'Logical design', 1),
(7140, 2587, 'Vertical Integration', 1),
(7141, 2588, 'Evaluation', 1),
(7142, 2589, 'Common Data Format', 1),
(7143, 2590, 'Architecture and Development', 1),
(7144, 2591, 'Star polyhedron', 1);

-- --------------------------------------------------------

--
-- Table structure for table `otp_table`
--

CREATE TABLE `otp_table` (
  `otp_id` int NOT NULL,
  `user_id` varchar(20) COLLATE utf8mb4_general_ci NOT NULL,
  `otp_code` varchar(6) COLLATE utf8mb4_general_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `is_used` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pending_users`
--

CREATE TABLE `pending_users` (
  `pending_id` int NOT NULL,
  `email` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `role` enum('teacher','student') COLLATE utf8mb4_general_ci NOT NULL,
  `firstname` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `middlename` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `lastname` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `block_id` int DEFAULT NULL,
  `region` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `province` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `barangay` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_otp_verified` tinyint(1) DEFAULT '0',
  `document_path` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `verification_status` enum('pending_upload','pending_approval','rejected') COLLATE utf8mb4_general_ci DEFAULT 'pending_upload',
  `admin_notes` text COLLATE utf8mb4_general_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `otp_code` varchar(6) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `otp_expires_at` datetime DEFAULT NULL,
  `otp_count` int DEFAULT '1',
  `last_otp_sent` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `programs`
--

CREATE TABLE `programs` (
  `program_id` int NOT NULL,
  `program_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `description` text COLLATE utf8mb4_general_ci,
  `is_active` tinyint(1) DEFAULT '1',
  `college_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `programs`
--

INSERT INTO `programs` (`program_id`, `program_name`, `description`, `is_active`, `college_id`) VALUES
(1, 'BSIT-SD', 'Bachelor of Science in Information Technology with specialization in System Development', 1, 10),
(2, 'BSIT-BA', 'Bachelor of Science in Information Technology with specialization in Business Analytics', 0, NULL),
(4, 'BSTM', 'Bachelor of Science in Tourism Management', 0, NULL),
(5, 'BSA', 'Bachelor of Science in Accountancy', 0, NULL),
(6, 'BSCS-DS', 'Bachelor of Science in Computer Science with Specialization in Data Science', 0, NULL),
(7, 'BSE', 'Bachelor of Science in Entrepreneurship', 0, NULL),
(8, 'BSME', 'Bachelor of Science in Mechanical Engineering', 0, NULL),
(9, 'BSPsy', 'Bachelor of Science in Psychology', 0, NULL),
(10, 'BAPsy', 'Bachelor of Arts in Psychology', 0, NULL),
(11, 'BAC', 'Bachelor of Arts in Communications', 0, NULL),
(12, 'BSAIS', 'Bachelor of Science in Accounting Information System', 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `questions`
--

CREATE TABLE `questions` (
  `question_id` int NOT NULL,
  `question_text` text COLLATE utf8mb4_general_ci NOT NULL,
  `question_type` enum('multiple_choice','true_false','identification','essay') COLLATE utf8mb4_general_ci DEFAULT NULL,
  `difficulty` enum('easy','medium','hard') COLLATE utf8mb4_general_ci DEFAULT NULL,
  `course_code` varchar(20) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_isolated` tinyint(1) DEFAULT '0',
  `teacher_id` varchar(10) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `questions`
--

INSERT INTO `questions` (`question_id`, `question_text`, `question_type`, `difficulty`, `course_code`, `is_isolated`, `teacher_id`) VALUES
(2572, 'Horizontal integration is primarily characterized by the creation of functional silos where each layer works upward to expedite the development process.', 'true_false', 'hard', 'CC-1100', 0, 'T26-0001'),
(2573, 'In the Common Data Format method, the application of Enterprise Application Integration is necessary to facilitate the transformation of data for cross-system acceptance.', 'true_false', 'hard', 'CC-1100', 0, 'T26-0001'),
(2574, 'The Feasibility Analysis phase is conducted after the Management Plan to ensure that the established budget and resource allocations are technically viable.', 'true_false', 'hard', 'CC-1100', 0, 'T26-0001'),
(2575, 'Data Integration (DI) specifically aims to consolidate disparate system information into a single server environment to enable the production of actionable intelligence.', 'true_false', 'hard', 'CC-1100', 0, 'T26-0001'),
(2576, 'Vertical integration is often considered the most cost-effective method due to its reliance on a limited number of specialized vendors and developers.', 'true_false', 'hard', 'CC-1100', 0, 'T26-0001'),
(2577, 'The physical design aspect of the System Integration Design phase is responsible for determining the specific hardware and network infrastructure required for the project.', 'true_false', 'hard', 'CC-1100', 0, 'T26-0001'),
(2578, 'Electronic Data Interchange (EDI) is fundamentally a method of replacing automated system-managed approaches with standardized paper-based documentation.', 'true_false', 'hard', 'CC-1100', 0, 'T26-0001'),
(2579, 'Within the Management Plan phase, the documentation of every step is considered essential for ensuring a smooth transition during phase integration.', 'true_false', 'hard', 'CC-1100', 0, 'T26-0001'),
(2580, 'Point-to-point integration is frequently referred to as star integration because it utilizes a centralized hub to minimize the number of required interfaces.', 'true_false', 'hard', 'CC-1100', 0, 'T26-0001'),
(2581, 'The Architecture and Development phase requires that scalability and security be prioritized to ensure the system can accommodate future upgrades.', 'true_false', 'hard', 'CC-1100', 0, 'T26-0001'),
(2582, 'Which integration strategy employs an Enterprise Service Bus (ESB) to minimize the number of direct interfaces between subsystems?', 'identification', 'hard', 'CC-1100', 0, 'T26-0001'),
(2583, 'What term describes the complex and often disorganized interconnectedness that results from extensive point-to-point integration?', 'identification', 'hard', 'CC-1100', 0, 'T26-0001'),
(2584, 'In which specific lifecycle phase are the technical, financial, and operational viability of a project scrutinized for approval?', 'identification', 'hard', 'CC-1100', 0, 'T26-0001'),
(2585, 'Which type of integration focuses on linking databases and workflows to ensure that changes in one system are instantly reflected across the IT environment?', 'identification', 'hard', 'CC-1100', 0, 'T26-0001'),
(2586, 'What design sub-component is dedicated to mapping out data flow, communication, and internal workflows between integrated components?', 'identification', 'hard', 'CC-1100', 0, 'T26-0001'),
(2587, 'Which method is categorized as the fastest integration strategy but carries significant risk due to high capital investment requirements?', 'identification', 'hard', 'CC-1100', 0, 'T26-0001'),
(2588, 'What is the name of the final lifecycle phase where user feedback is gathered to optimize the system for long-term stability?', 'identification', 'hard', 'CC-1100', 0, 'T26-0001'),
(2589, 'Which integration method relies on data translation to eliminate the need for a separate adapter for every distinct data format?', 'identification', 'hard', 'CC-1100', 0, 'T26-0001'),
(2590, 'During which phase are blueprints created and specific communication protocols, such as APIs, selected for the integration process?', 'identification', 'hard', 'CC-1100', 0, 'T26-0001'),
(2591, 'What geometric term is used to describe the visual structure of subsystems once they are fully interconnected via the star integration method?', 'identification', 'hard', 'CC-1100', 0, 'T26-0001');

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `student_id` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `firstname` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `middlename` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `lastname` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `block_id` int DEFAULT NULL,
  `region` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `province` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `city` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `barangay` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`student_id`, `email`, `firstname`, `middlename`, `lastname`, `block_id`, `region`, `province`, `city`, `barangay`) VALUES
('S26-0001', 'ninio123@gmail.com', 'Justin Dion', 'Bibon', 'Salaveria', 30, 'Region I (Ilocos Region)', 'Ilocos Norte', 'Adams', 'Adams (Pob.)'),
('S26-0002', 'jinggoy123@gmail.com', 'James', 'Montenegro', 'Almonte', 30, 'Region I (Ilocos Region)', 'Ilocos Norte', 'Adams', 'Adams (Pob.)');

-- --------------------------------------------------------

--
-- Table structure for table `student_answers`
--

CREATE TABLE `student_answers` (
  `answer_id` int NOT NULL,
  `attempt_id` int DEFAULT NULL,
  `question_id` int DEFAULT NULL,
  `submitted_answer` text COLLATE utf8mb4_general_ci,
  `is_correct` tinyint(1) DEFAULT '0',
  `is_flagged` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_answers`
--

INSERT INTO `student_answers` (`answer_id`, `attempt_id`, `question_id`, `submitted_answer`, `is_correct`, `is_flagged`) VALUES
(4587, 243, 2579, 'False', 0, 0),
(4594, 243, 2587, '', 0, 0),
(4595, 243, 2575, 'False', 0, 0),
(4598, 243, 2580, 'True', 0, 0),
(4600, 243, 2583, '', 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `teachers`
--

CREATE TABLE `teachers` (
  `teacher_id` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `firstname` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `middlename` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `lastname` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `region` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `province` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `city` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `barangay` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `teachers`
--

INSERT INTO `teachers` (`teacher_id`, `email`, `firstname`, `middlename`, `lastname`, `region`, `province`, `city`, `barangay`) VALUES
('T26-0001', 'justindionsalaveria@gmail.com', 'Justin Dion', 'Bibon', 'Salaveria', 'Region IV-A (CALABARZON)', 'Laguna', 'Santa Cruz (Capital)', 'Labuin');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` varchar(10) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(200) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `role` enum('super_admin','admin','teacher','student') COLLATE utf8mb4_general_ci DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1',
  `otp_count` int DEFAULT '0',
  `last_otp_sent` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `email`, `password`, `role`, `is_verified`, `created_at`, `is_active`, `otp_count`, `last_otp_sent`) VALUES
('A26-0000', 'justindion180@gmail.com', 'scrypt:32768:8:1$U6dSaNNxSJAP6jNi$9af5ecf8f5d6c73f8a6f923e3036ab9d7515f6f4f13246f7085402b3d56d83eca2a3f9171e15154030381b2cbc8292d90b1d94444dbd8a05ba6e3739fe0c38d7', 'super_admin', 1, '2026-03-23 06:24:05', 1, 2, '2026-05-03 15:36:39'),
('A26-0001', 'gonzalvo.tyrael@gmail.com', 'scrypt:32768:8:1$fWpnuZK9VixIhAp3$8de467209ea970f8e748e6267afd312e1a2344897e825c8ac743ca474cbc441faec3cec05366db536aabf26d00576e799dd16e3373c9bf6270fd306a5fa25608', 'admin', 1, '2026-07-02 14:24:08', 1, 0, NULL),
('S26-0001', 'ninio123@gmail.com', 'scrypt:32768:8:1$JQm9Pe5k9aY7j3eb$90ebfbd87a1eea660d69d7325d8e16f1426550222cf3e0a199479c30b9e35b313b0cf3af681ff8bd640bb79d9ebe578cce8814fcd74a19d79213471fed35ccf4', 'student', 1, '2026-07-07 13:46:21', 1, 0, NULL),
('S26-0002', 'jinggoy123@gmail.com', 'scrypt:32768:8:1$bft4ceOxWTeKhyGb$ea29ea548d82489cc4fea7bbf5953cecb0c0dfb5d82565a1550838d093d237dc70391aa2081a549cfe15ae3f14fe3adddff34031c77e8d8a5294272b90636e62', 'student', 1, '2026-07-08 15:24:32', 1, 0, NULL),
('SUPER001', 'jamesmatthewalmonte45@gmail.com', 'scrypt:32768:8:1$4j8bqUUcuAoYquDU$633b6616fa3249e7c6042d64c54d677f13d55f30d5025c70a104c96cddc1ce490828fe065bed71320b8ed9d3a08d429b85c5050209b37ae104d9b381a23b41be', 'super_admin', 1, '2026-07-06 13:40:42', 1, 0, NULL),
('T26-0001', 'justindionsalaveria@gmail.com', 'scrypt:32768:8:1$weOQ6d0b73a4DWBq$3232d13d02631cba62f81582d71c1ba66f267f680ebbd669747c682266ea3bdbfd11753a62af76f9b7152f155a5d32fb483d38f3d98859117c4194cc467554c9', 'teacher', 1, '2026-07-07 13:26:56', 1, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `violation_logs`
--

CREATE TABLE `violation_logs` (
  `log_id` int NOT NULL,
  `attempt_id` int DEFAULT NULL,
  `violation_type` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `violation_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `violation_logs`
--

INSERT INTO `violation_logs` (`log_id`, `attempt_id`, `violation_type`, `violation_time`, `latitude`, `longitude`) VALUES
(655, 243, 'Exam Started', '2026-07-08 23:05:04', 14.24859742, 121.39640565);

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
  MODIFY `block_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `colleges`
--
ALTER TABLE `colleges`
  MODIFY `college_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `enrollments`
--
ALTER TABLE `enrollments`
  MODIFY `enrollment_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT for table `exams`
--
ALTER TABLE `exams`
  MODIFY `exam_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `exam_attempts`
--
ALTER TABLE `exam_attempts`
  MODIFY `attempt_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=244;

--
-- AUTO_INCREMENT for table `options`
--
ALTER TABLE `options`
  MODIFY `option_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7145;

--
-- AUTO_INCREMENT for table `otp_table`
--
ALTER TABLE `otp_table`
  MODIFY `otp_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `pending_users`
--
ALTER TABLE `pending_users`
  MODIFY `pending_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `programs`
--
ALTER TABLE `programs`
  MODIFY `program_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `questions`
--
ALTER TABLE `questions`
  MODIFY `question_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2592;

--
-- AUTO_INCREMENT for table `student_answers`
--
ALTER TABLE `student_answers`
  MODIFY `answer_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4601;

--
-- AUTO_INCREMENT for table `violation_logs`
--
ALTER TABLE `violation_logs`
  MODIFY `log_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=656;

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
