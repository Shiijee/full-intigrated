-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 11, 2026 at 03:12 PM
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
-- Database: `db_voting`
--

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `id` int(11) NOT NULL,
  `college_id` int(11) DEFAULT NULL,
  `title` varchar(200) NOT NULL,
  `body` text NOT NULL,
  `type` enum('general','election','winner','reminder') NOT NULL DEFAULT 'general',
  `status` enum('draft','published') NOT NULL DEFAULT 'draft',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `image_url` varchar(300) DEFAULT NULL,
  `is_pinned` tinyint(1) NOT NULL DEFAULT 0,
  `created_by` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `announcements`
--

INSERT INTO `announcements` (`id`, `college_id`, `title`, `body`, `type`, `status`, `created_at`, `updated_at`, `image_url`, `is_pinned`, `created_by`) VALUES
(1, 5, 'asda', 'adasdadadadas', 'general', 'published', '2026-06-28 13:44:38', '2026-06-28 13:44:38', NULL, 0, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` text DEFAULT NULL,
  `details` text DEFAULT NULL,
  `target_type` varchar(50) DEFAULT NULL,
  `target_id` int(11) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `user_id`, `action`, `details`, `target_type`, `target_id`, `timestamp`) VALUES
(1, NULL, 'ACTIVATE_ELECTION', 'Election set to status: active (ID: 30)', 'Election', 30, '2026-05-06 17:25:16'),
(2, NULL, 'PAUSE_ELECTION', 'Paused election ID: 30', 'Election', 30, '2026-05-06 17:25:19'),
(3, 46, 'DELETE_ELECTION', 'Deleted election ID: 30', 'Election', 30, '2026-05-07 04:46:05'),
(4, 46, 'CREATE_VOTER', 'Created voter: James Matthew Almonte (ID: 241-5-1111)', 'Voter', 47, '2026-05-07 04:56:10'),
(5, 46, 'CREATE_VOTER', 'Created voter: Justin Salaveria (ID: 241-5-2222)', 'Voter', 49, '2026-05-07 05:28:01'),
(6, 48, 'CREATE_VOTER', 'Created voter: Tyrael Gonzalvo (ID: 241-3-3333)', 'Voter', 50, '2026-05-07 05:30:49'),
(7, 48, 'CREATE_ELECTION', 'Created election: BSTEST ELECTION', 'Election', 32, '2026-05-07 05:32:44'),
(8, 48, 'CREATE_POSITION', 'Created position: President (Election ID: 32)', 'Position', 35, '2026-05-07 05:39:06'),
(9, 48, 'CREATE_POSITION', 'Created position: Vice President (Election ID: 32)', 'Position', 36, '2026-05-07 05:39:21'),
(10, 48, 'CREATE_CANDIDATE', 'Added candidate: Test 123 (Position ID: 35)', 'Candidate', 40, '2026-05-07 05:40:12'),
(11, 48, 'DELETE_CANDIDATE', 'Deleted candidate ID: 40', 'Candidate', 40, '2026-05-07 05:40:49'),
(12, 46, 'CREATE_ELECTION', 'Created election: Student Council ', 'Election', 33, '2026-05-07 05:59:35'),
(13, 46, 'CREATE_POSITION', 'Created position: President (Election ID: 33)', 'Position', 37, '2026-05-07 05:59:49'),
(14, 46, 'CREATE_POSITION', 'Created position: Vice President (Election ID: 33)', 'Position', 38, '2026-05-07 05:59:52'),
(15, 46, 'CREATE_CANDIDATE', 'Added candidate: James Matthew Almonte (Position ID: 37)', 'Candidate', 41, '2026-05-07 06:00:16'),
(16, 46, 'CREATE_CANDIDATE', 'Added candidate: James ALMONTE (Position ID: 37)', 'Candidate', 42, '2026-05-07 06:00:57'),
(17, 46, 'CREATE_CANDIDATE', 'Added candidate: www www (Position ID: 38)', 'Candidate', 43, '2026-05-07 06:01:24'),
(18, 46, 'DELETE_ELECTION', 'Deleted election ID: 33', 'Election', 33, '2026-05-07 06:12:04'),
(19, 46, 'CREATE_ELECTION', 'Created election: Yes', 'Election', 34, '2026-05-07 06:12:51'),
(20, 46, 'ARCHIVE_ELECTION', 'Archived election ID: 34 (was: completed)', 'Election', 34, '2026-05-07 06:15:18'),
(21, 46, 'ACTIVATE_ELECTION', 'Election set to status: completed (ID: 34)', 'Election', 34, '2026-05-07 06:15:22'),
(22, 46, 'ARCHIVE_ELECTION', 'Archived election ID: 34 (was: completed)', 'Election', 34, '2026-05-07 06:15:29'),
(23, 46, 'ACTIVATE_ELECTION', 'Election set to status: completed (ID: 34)', 'Election', 34, '2026-05-07 06:15:36'),
(24, 46, 'DELETE_ELECTION', 'Deleted election ID: 34', 'Election', 34, '2026-05-07 06:15:46'),
(25, 48, 'CREATE_ELECTION', 'Created election: ELEction', 'Election', 35, '2026-05-07 06:52:20'),
(26, 48, 'CREATE_POSITION', 'Created position: President (Election ID: 35)', 'Position', 39, '2026-05-07 06:52:52'),
(27, 48, 'CREATE_CANDIDATE', 'Added candidate: sdsfs sdfs (Position ID: 39)', 'Candidate', 44, '2026-05-07 06:53:06'),
(28, 48, 'CREATE_CANDIDATE', 'Added candidate: sdf seeew (Position ID: 39)', 'Candidate', 45, '2026-05-07 06:53:14'),
(29, 48, 'DELETE_VOTER', 'Permanently deleted voter ID: 50', 'Voter', 50, '2026-05-07 07:01:15'),
(30, 46, 'CREATE_ELECTION', 'Created election: es', 'Election', 36, '2026-07-02 09:18:34'),
(31, 46, 'CREATE_POSITION', 'Created position: Vice President (Election ID: 36)', 'Position', 40, '2026-07-02 09:18:50'),
(32, 46, 'CREATE_CANDIDATE', 'Added candidate: dadad adad (Position ID: 40)', 'Candidate', 46, '2026-07-02 09:19:20'),
(33, 46, 'ACTIVATE_ELECTION', 'Election set to status: active (ID: 36)', 'Election', 36, '2026-07-02 09:19:30');

-- --------------------------------------------------------

--
-- Table structure for table `candidates`
--

CREATE TABLE `candidates` (
  `id` int(11) NOT NULL,
  `position_id` int(11) NOT NULL,
  `student_id` varchar(50) NOT NULL,
  `firstname` varchar(50) NOT NULL,
  `middlename` varchar(50) DEFAULT NULL,
  `surname` varchar(50) NOT NULL,
  `platform` text DEFAULT NULL,
  `partylist` varchar(100) DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `college_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `candidates`
--

INSERT INTO `candidates` (`id`, `position_id`, `student_id`, `firstname`, `middlename`, `surname`, `platform`, `partylist`, `photo`, `status`, `created_at`, `college_id`) VALUES
(44, 39, 'voter3(1)', 'sdsfs', '', 'sdfs', '', '', NULL, 'approved', '2026-05-07 06:53:06', 3),
(45, 39, 'voter3(2)', 'sdf', '', 'seeew', '', '', NULL, 'approved', '2026-05-07 06:53:14', 3),
(46, 40, 'voter5(1)', 'dadad', 'ada', 'adad', 'adsadsad', 'sadas', NULL, 'approved', '2026-07-02 09:19:20', 5);

-- --------------------------------------------------------

--
-- Table structure for table `colleges`
--

CREATE TABLE `colleges` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `colleges`
--

INSERT INTO `colleges` (`id`, `name`, `created_at`) VALUES
(1, 'College of Engineering', '2026-04-07 03:28:39'),
(2, 'College of Nursing', '2026-04-07 03:28:39'),
(3, 'College of Business Administration', '2026-04-07 03:28:39'),
(4, 'College of Education', '2026-04-07 03:28:39'),
(5, 'College of Arts and Sciences', '2026-04-07 03:28:39'),
(7, 'College of Computer Studies', '2026-05-06 11:48:20');

-- --------------------------------------------------------

--
-- Table structure for table `elections`
--

CREATE TABLE `elections` (
  `id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `status` enum('upcoming','active','paused','completed','cancelled','draft') DEFAULT 'upcoming',
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `college_id` int(11) DEFAULT NULL,
  `previous_status` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `elections`
--

INSERT INTO `elections` (`id`, `title`, `description`, `start_date`, `end_date`, `status`, `created_by`, `created_at`, `college_id`, `previous_status`) VALUES
(32, 'BSTEST ELECTION', 'TESTING123', '2026-05-08 13:32:00', '2026-05-09 13:32:00', 'completed', 48, '2026-05-07 05:32:44', 3, NULL),
(35, 'ELEction', '', '2026-05-07 14:53:00', '2026-05-07 14:57:00', 'completed', 48, '2026-05-07 06:52:20', 3, NULL),
(36, 'es', 'efsef', '2026-07-11 17:18:00', '2026-07-23 17:18:00', 'active', 46, '2026-07-02 09:18:34', 5, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `otp_codes`
--

CREATE TABLE `otp_codes` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `otp` varchar(100) DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `used` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `otp_codes`
--

INSERT INTO `otp_codes` (`id`, `user_id`, `otp`, `expires_at`, `used`) VALUES
(1, NULL, '7419ba', '2026-05-07 01:40:22', 0),
(2, NULL, '933f2108a24c0d388827d74ec0c83cfb49edcf4df2bfaee619e59a817236b301', '2026-05-07 01:48:02', 1),
(3, NULL, '0a09e7042dfe9a94a14eac3356c6f29d851e77886e6af9de1d9151debb165566', '2026-05-07 01:48:52', 1),
(4, NULL, 'efbbaaafabfce48b671b6512e55e22f6c5f090e676722818062e2fe8d169ad4c', '2026-05-07 01:53:40', 1),
(5, 46, '78be611670c8accce96000dba22ec1a88c2c4da6fb5617fe65f2bb43419b71a9', '2026-05-07 01:57:46', 1),
(6, 46, '0c784e16ce6e7470b11b48110be8731a375efc8db4fee4edadde0bc90c3f906d', '2026-05-07 01:59:06', 1),
(7, 46, '69a901c2f4ee600be9dccaf4f6e9250de7a5a05083c1c49212266366c1060415', '2026-05-07 02:01:38', 1),
(8, 46, 'fbc685adcc7ee8917189b0c4839317d83f1702c82ebfefdeb126241e77de15d5', '2026-05-07 12:48:58', 1),
(9, 46, '3b9220f5d29e4fa4a10ee904510a73c79cb3807665d59281e7c7345ef3a205d5', '2026-05-07 12:50:19', 1),
(10, 46, 'efaed0d5aee55af63f3874699b3fd6f67ad746a272f279fa6e888fbb916623ad', '2026-05-07 12:56:12', 0),
(11, 46, '79aeaf1b06fd48eb1664673ffc56e7338cf4d7ee5fc6f3073755b082a95ff3cf', '2026-05-07 12:56:15', 0),
(12, 46, '0b89b53f16dd17cfeedb39469e176aca5af561e25beab6d86d2ca4f5dfdd39a3', '2026-05-07 12:58:22', 0),
(13, 47, '6b3968e1427f8646af5e7f5e682cc0c0624f0e9401947a4e19cd3764e2013e3a', '2026-05-07 13:01:53', 1),
(14, 48, '82bfd9b51e160512845fadd7496d7a7f5d9a27905354a0fb63d07796c2f1d282', '2026-05-07 13:34:28', 1),
(16, 49, '42e09a57cb7fcfce282af54cf7bb5a27d25e0b245c67df7cfb85ffc6c45b2b2a', '2026-05-07 13:40:39', 1),
(17, 46, '9d0a7e8c29b43981857cba23a8bae5b8558a9becbf34fcd53b33dd0fb36a401e', '2026-06-27 23:49:55', 1),
(18, 46, 'ded488d7289ebafdd2f2d11f7cc8d8a0d929107567fabcd3c7550f50b8cc1bd4', '2026-06-28 21:20:44', 1),
(19, 49, '0476db65ef5927f8e9dd5721c053cadeadfa049060d326444121837bef806186', '2026-06-28 21:24:51', 1),
(20, 49, '2fbb8b4a8110fbfb6473136ce76d9fb4a0aeed3e5c009e71d13034c564f607a1', '2026-06-28 21:25:49', 1);

-- --------------------------------------------------------

--
-- Table structure for table `positions`
--

CREATE TABLE `positions` (
  `id` int(11) NOT NULL,
  `election_id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `max_votes` int(11) DEFAULT 1,
  `display_order` int(11) DEFAULT 0,
  `college_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `positions`
--

INSERT INTO `positions` (`id`, `election_id`, `title`, `description`, `max_votes`, `display_order`, `college_id`) VALUES
(35, 32, 'President', 'Leads the Student Council and represents the student body.', 1, 1, 3),
(36, 32, 'Vice President', 'Assists the President and presides in their absence.', 1, 2, 3),
(39, 35, 'President', 'Leads the Student Council and represents the student body.', 1, 1, 3),
(40, 36, 'Vice President', 'Assists the President and presides in their absence.', 1, 0, 5);

-- --------------------------------------------------------

--
-- Table structure for table `system_logs`
--

CREATE TABLE `system_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(100) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `system_logs`
--

INSERT INTO `system_logs` (`id`, `user_id`, `action`, `details`, `created_at`) VALUES
(2, NULL, 'logout', 'User logged out', '2026-03-29 10:02:00'),
(3, NULL, 'logout', 'User logged out', '2026-03-29 10:04:22'),
(4, 18, 'logout', 'User logged out', '2026-03-29 10:40:02'),
(5, NULL, 'logout', 'User logged out', '2026-04-07 03:47:00'),
(6, NULL, 'logout', 'User logged out', '2026-04-07 04:34:27'),
(7, NULL, 'logout', 'User logged out', '2026-04-07 04:44:30'),
(8, NULL, 'logout', 'User logged out', '2026-04-07 04:52:52'),
(9, NULL, 'logout', 'User logged out', '2026-04-07 10:13:39'),
(10, NULL, 'logout', 'User logged out', '2026-04-07 10:15:16'),
(11, 18, 'logout', 'User logged out', '2026-04-07 10:21:06'),
(12, 18, 'logout', 'User logged out', '2026-04-07 13:52:14'),
(13, 18, 'logout', 'User logged out', '2026-04-07 14:46:27'),
(14, 18, 'logout', 'User logged out', '2026-04-07 15:39:31'),
(15, NULL, 'logout', 'User logged out', '2026-04-20 07:10:34'),
(16, NULL, 'logout', 'User logged out', '2026-04-20 07:27:55'),
(17, NULL, 'logout', 'User logged out', '2026-04-20 07:49:07'),
(18, NULL, 'logout', 'User logged out', '2026-04-27 10:39:21'),
(19, NULL, 'logout', 'User logged out', '2026-04-27 10:41:13'),
(20, NULL, 'logout', 'User logged out', '2026-04-27 10:42:49'),
(21, NULL, 'logout', 'User logged out', '2026-04-27 10:51:15'),
(22, NULL, 'logout', 'User logged out', '2026-04-27 11:02:48'),
(23, NULL, 'logout', 'User logged out', '2026-04-30 00:10:49'),
(24, NULL, 'logout', 'User logged out', '2026-04-30 00:29:50'),
(25, NULL, 'logout', 'User logged out', '2026-05-01 02:01:20'),
(26, NULL, 'logout', 'User logged out', '2026-05-01 03:36:06'),
(27, 18, 'logout', 'User logged out', '2026-05-01 03:39:30'),
(28, NULL, 'logout', 'User logged out', '2026-05-01 03:57:44'),
(29, NULL, 'logout', 'User logged out', '2026-05-01 04:01:35'),
(30, NULL, 'logout', 'User logged out', '2026-05-01 04:03:24'),
(31, NULL, 'logout', 'User logged out', '2026-05-01 04:04:44'),
(32, NULL, 'logout', 'User logged out', '2026-05-01 08:17:22'),
(33, 18, 'logout', 'User logged out', '2026-05-01 08:18:38'),
(34, 18, 'logout', 'User logged out', '2026-05-01 08:18:51'),
(35, 18, 'logout', 'User logged out', '2026-05-01 08:19:03'),
(36, NULL, 'logout', 'User logged out', '2026-05-01 08:29:14'),
(37, NULL, 'logout', 'User logged out', '2026-05-01 08:53:08'),
(38, 18, 'logout', 'User logged out', '2026-05-01 08:57:48'),
(39, NULL, 'logout', 'User logged out', '2026-05-01 08:59:30'),
(40, NULL, 'logout', 'User logged out', '2026-05-01 09:05:31'),
(41, NULL, 'logout', 'User logged out', '2026-05-01 09:08:29'),
(42, NULL, 'logout', 'User logged out', '2026-05-01 09:09:19'),
(43, NULL, 'logout', 'User logged out', '2026-05-01 09:10:49'),
(44, NULL, 'logout', 'User logged out', '2026-05-01 09:11:53'),
(45, NULL, 'logout', 'User logged out', '2026-05-01 09:12:44'),
(46, NULL, 'logout', 'User logged out', '2026-05-01 09:13:13'),
(47, NULL, 'logout', 'User logged out', '2026-05-01 09:18:38'),
(48, NULL, 'logout', 'User logged out', '2026-05-01 09:18:55'),
(49, NULL, 'logout', 'User logged out', '2026-05-01 14:40:16'),
(50, NULL, 'logout', 'User logged out', '2026-05-01 17:32:34'),
(51, NULL, 'logout', 'User logged out', '2026-05-01 17:32:47'),
(52, NULL, 'logout', 'User logged out', '2026-05-01 17:33:08'),
(53, 18, 'logout', 'User logged out', '2026-05-01 18:35:54'),
(54, NULL, 'logout', 'User logged out', '2026-05-01 18:40:06'),
(55, NULL, 'logout', 'User logged out', '2026-05-01 18:46:46'),
(56, NULL, 'logout', 'User logged out', '2026-05-01 18:48:52'),
(57, NULL, 'logout', 'User logged out', '2026-05-01 18:57:52'),
(58, NULL, 'logout', 'User logged out', '2026-05-01 18:59:06'),
(59, NULL, 'logout', 'User logged out', '2026-05-01 19:00:44'),
(60, 18, 'logout', 'User logged out', '2026-05-01 19:08:41'),
(61, NULL, 'logout', 'User logged out', '2026-05-01 19:09:47'),
(62, NULL, 'logout', 'User logged out', '2026-05-01 19:23:28'),
(63, NULL, 'logout', 'User logged out', '2026-05-01 19:24:15'),
(64, NULL, 'logout', 'User logged out', '2026-05-01 19:28:23'),
(65, NULL, 'logout', 'User logged out', '2026-05-01 19:29:09'),
(66, NULL, 'logout', 'User logged out', '2026-05-01 20:04:52'),
(67, NULL, 'logout', 'User logged out', '2026-05-01 20:05:53'),
(68, NULL, 'logout', 'User logged out', '2026-05-01 20:10:32'),
(69, NULL, 'logout', 'User logged out', '2026-05-01 20:11:11'),
(70, NULL, 'logout', 'User logged out', '2026-05-01 20:17:58'),
(71, NULL, 'logout', 'User logged out', '2026-05-01 20:18:11'),
(72, NULL, 'logout', 'User logged out', '2026-05-01 20:18:43'),
(73, NULL, 'logout', 'User logged out', '2026-05-01 20:18:52'),
(74, NULL, 'logout', 'User logged out', '2026-05-01 20:19:24'),
(75, NULL, 'logout', 'User logged out', '2026-05-02 06:57:54'),
(76, NULL, 'logout', 'User logged out', '2026-05-02 10:14:18'),
(77, NULL, 'logout', 'User logged out', '2026-05-02 14:25:25'),
(78, NULL, 'logout', 'User logged out', '2026-05-02 15:25:35'),
(79, NULL, 'logout', 'User logged out', '2026-05-02 15:35:51'),
(80, NULL, 'logout', 'User logged out', '2026-05-02 15:37:34'),
(81, NULL, 'logout', 'User logged out', '2026-05-02 15:37:53'),
(82, NULL, 'logout', 'User logged out', '2026-05-02 15:38:29'),
(83, NULL, 'logout', 'User logged out', '2026-05-03 07:17:27'),
(84, NULL, 'logout', 'User logged out', '2026-05-03 07:44:20'),
(85, 18, 'logout', 'User logged out', '2026-05-03 14:02:14'),
(86, NULL, 'logout', 'User logged out', '2026-05-03 15:07:39'),
(87, NULL, 'logout', 'User logged out', '2026-05-03 15:08:53'),
(88, NULL, 'logout', 'User logged out', '2026-05-03 18:11:52'),
(89, NULL, 'logout', 'User logged out', '2026-05-03 18:16:15'),
(90, NULL, 'logout', 'User logged out', '2026-05-03 18:57:30'),
(91, 18, 'login', 'User logged in — SUPER001', '2026-05-03 18:57:57'),
(92, 18, 'logout', 'User logged out', '2026-05-03 18:58:27'),
(93, NULL, 'login', 'User logged in (trusted device) — admin-0001', '2026-05-03 18:58:38'),
(94, NULL, 'logout', 'User logged out', '2026-05-03 18:58:52'),
(95, NULL, 'login', 'User logged in (trusted device) — admin-0001', '2026-05-03 19:07:08'),
(96, NULL, 'logout', 'User logged out', '2026-05-03 19:07:31'),
(97, 18, 'logout', 'User logged out', '2026-05-03 19:08:54'),
(98, NULL, 'login', 'User logged in — admin-0001', '2026-05-03 19:09:24'),
(99, NULL, 'login', 'User logged in (trusted device) — 241-1-0003', '2026-05-03 19:13:39'),
(100, NULL, 'logout', 'User logged out', '2026-05-03 19:35:17'),
(101, NULL, 'logout', 'User logged out', '2026-05-03 19:50:53'),
(102, 18, 'login', 'User logged in — SUPER001', '2026-05-03 19:57:48'),
(103, 18, 'logout', 'User logged out', '2026-05-03 19:57:53'),
(104, NULL, 'login', 'User logged in (trusted device) — admin-0001', '2026-05-03 19:57:58'),
(105, NULL, 'logout', 'User logged out', '2026-05-03 19:58:02'),
(106, 18, 'login', 'User logged in (trusted device) — SUPER001', '2026-05-03 19:58:10'),
(107, 18, 'logout', 'User logged out', '2026-05-03 19:58:15'),
(108, NULL, 'login', 'User logged in (trusted device) — 241-1-0002', '2026-05-03 19:58:19'),
(109, NULL, 'logout', 'User logged out', '2026-05-03 19:58:36'),
(110, 18, 'login', 'User logged in — SUPER001', '2026-05-04 07:46:49'),
(111, 18, 'logout', 'User logged out', '2026-05-04 07:47:30'),
(112, NULL, 'login', 'User logged in — admin-0003', '2026-05-04 07:48:12'),
(113, NULL, 'login', 'User logged in (trusted device) — 241-5-0001', '2026-05-04 07:50:42'),
(114, NULL, 'logout', 'User logged out', '2026-05-04 08:45:24'),
(115, 18, 'login', 'User logged in (trusted device) — SUPER001', '2026-05-04 08:45:36'),
(116, NULL, 'login', 'User logged in (trusted device) — admin-0001', '2026-05-04 11:14:58'),
(117, NULL, 'logout', 'User logged out', '2026-05-04 11:35:03'),
(118, NULL, 'login', 'User logged in (trusted device) — 241-1-0003', '2026-05-04 14:54:26'),
(119, NULL, 'login', 'User logged in (trusted device) — admin-0001', '2026-05-04 14:54:53'),
(120, 18, 'login', 'User logged in (trusted device) — SUPER001', '2026-05-05 07:50:06'),
(121, NULL, 'login', 'User logged in — admin-0005', '2026-05-05 07:51:30'),
(122, NULL, 'logout', 'User logged out', '2026-05-05 07:51:44'),
(123, NULL, 'login', 'User logged in — admin-0004', '2026-05-05 07:52:51'),
(124, NULL, 'logout', 'User logged out', '2026-05-05 07:53:05'),
(125, NULL, 'login', 'User logged in (trusted device) — admin-0001', '2026-05-05 07:53:39'),
(126, 18, 'logout', 'User logged out', '2026-05-05 08:22:51'),
(127, NULL, 'login', 'User logged in — 241-1-0002', '2026-05-05 08:24:09'),
(128, NULL, 'logout', 'User logged out', '2026-05-05 08:58:52'),
(129, NULL, 'login', 'User logged in — admin-0003', '2026-05-05 08:59:55'),
(130, NULL, 'logout', 'User logged out', '2026-05-05 09:00:23'),
(131, NULL, 'logout', 'User logged out', '2026-05-05 09:06:12'),
(132, NULL, 'login', 'User logged in — admin-0001', '2026-05-06 04:21:07'),
(133, NULL, 'login', 'User logged in (trusted device) — admin-0001', '2026-05-06 05:05:18'),
(134, NULL, 'logout', 'User logged out', '2026-05-06 05:49:29'),
(135, NULL, 'login', 'User logged in (trusted device) — admin-0001', '2026-05-06 06:02:42'),
(136, NULL, 'logout', 'User logged out', '2026-05-06 06:10:14'),
(137, NULL, 'login', 'User logged in (trusted device) — admin-0001', '2026-05-06 06:12:31'),
(138, NULL, 'login', 'User logged in — 241-1-0002', '2026-05-06 06:30:49'),
(139, NULL, 'logout', 'User logged out', '2026-05-06 06:31:13'),
(140, 18, 'login', 'User logged in — SUPER001', '2026-05-06 11:47:18'),
(141, 18, 'logout', 'User logged out', '2026-05-06 12:36:55'),
(142, 18, 'login', 'User logged in (trusted device) — SUPER001', '2026-05-06 12:37:19'),
(143, 18, 'logout', 'User logged out', '2026-05-06 12:46:08'),
(144, 18, 'login', 'User logged in (trusted device) — SUPER001', '2026-05-06 12:46:22'),
(145, 18, 'login', 'User logged in — SUPER001', '2026-05-06 12:49:56'),
(146, 18, 'login', 'User logged in — SUPER001', '2026-05-06 13:59:57'),
(147, 18, 'logout', 'User logged out', '2026-05-06 14:20:29'),
(148, NULL, 'login', 'User logged in — admin-0003', '2026-05-06 14:21:25'),
(149, NULL, 'login', 'User logged in — 241-5-0363', '2026-05-06 14:29:58'),
(150, NULL, 'logout', 'User logged out', '2026-05-06 14:37:49'),
(151, NULL, 'login', 'User logged in — 241-5-1234', '2026-05-06 14:38:22'),
(152, NULL, 'logout', 'User logged out', '2026-05-06 14:39:00'),
(153, NULL, 'login', 'User logged in (trusted device) — admin-0003', '2026-05-06 14:39:15'),
(154, NULL, 'logout', 'User logged out', '2026-05-06 15:10:40'),
(155, NULL, 'login', 'User logged in (trusted device) — 241-5-0363', '2026-05-06 15:11:00'),
(156, NULL, 'logout', 'User logged out', '2026-05-06 15:11:19'),
(157, NULL, 'login', 'User logged in — 241-5-1234', '2026-05-06 15:11:45'),
(158, 18, 'login', 'User logged in (trusted device) — SUPER001', '2026-05-06 15:51:45'),
(159, 18, 'logout', 'User logged out', '2026-05-06 15:54:03'),
(160, NULL, 'login', 'User logged in — admin-0004', '2026-05-06 15:55:39'),
(161, NULL, 'logout', 'User logged out', '2026-05-06 15:58:02'),
(162, NULL, 'login', 'User logged in — 241-1-1111', '2026-05-06 15:59:03'),
(163, NULL, 'logout', 'User logged out', '2026-05-06 16:01:59'),
(164, NULL, 'logout', 'User logged out', '2026-05-06 16:02:20'),
(165, 18, 'login', 'User logged in (trusted device) — SUPER001', '2026-05-06 16:02:29'),
(166, NULL, 'login', 'User logged in (trusted device) — admin-0003', '2026-05-06 16:02:56'),
(167, 18, 'logout', 'User logged out', '2026-05-06 16:35:58'),
(168, NULL, 'login', 'User logged in (trusted device) — admin-0004', '2026-05-06 16:36:32'),
(169, NULL, 'logout', 'User logged out', '2026-05-06 16:54:03'),
(170, NULL, 'logout', 'User logged out', '2026-05-06 16:57:23'),
(171, 18, 'login', 'User logged in — SUPER001', '2026-05-06 16:59:44'),
(172, NULL, 'login', 'User logged in — admin-0003', '2026-05-06 17:00:16'),
(173, 18, 'logout', 'User logged out', '2026-05-06 17:34:49'),
(175, 46, 'login', 'User logged in — admin-0002', '2026-05-06 17:57:07'),
(176, 46, 'login', 'User logged in — admin-0002', '2026-05-07 04:45:50'),
(177, 46, 'logout', 'User logged out', '2026-05-07 04:46:11'),
(178, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-05-07 04:55:35'),
(179, 46, 'logout', 'User logged out', '2026-05-07 04:56:42'),
(180, 47, 'login', 'User logged in — 241-5-1111', '2026-05-07 04:57:15'),
(181, 47, 'logout', 'User logged out', '2026-05-07 04:58:41'),
(182, 18, 'login', 'User logged in (trusted device) — SUPER001', '2026-05-07 04:59:43'),
(183, 18, 'logout', 'User logged out', '2026-05-07 05:10:20'),
(184, 47, 'login', 'User logged in (trusted device) — 241-5-1111', '2026-05-07 05:10:30'),
(185, 47, 'logout', 'User logged out', '2026-05-07 05:10:37'),
(186, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-05-07 05:10:50'),
(187, 46, 'logout', 'User logged out', '2026-05-07 05:22:11'),
(188, 18, 'login', 'User logged in (trusted device) — SUPER001', '2026-05-07 05:22:38'),
(189, 18, 'logout', 'User logged out', '2026-05-07 05:23:52'),
(190, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-05-07 05:24:04'),
(191, 46, 'logout', 'User logged out', '2026-05-07 05:29:13'),
(192, 48, 'login', 'User logged in — admin-0003', '2026-05-07 05:29:57'),
(193, 48, 'logout', 'User logged out', '2026-05-07 05:32:53'),
(194, 47, 'login', 'User logged in (trusted device) — 241-5-1111', '2026-05-07 05:33:10'),
(195, 47, 'logout', 'User logged out', '2026-05-07 05:33:27'),
(196, NULL, 'login', 'User logged in — 241-3-3333', '2026-05-07 05:33:56'),
(197, NULL, 'logout', 'User logged out', '2026-05-07 05:34:51'),
(198, 49, 'login', 'User logged in — 241-5-2222', '2026-05-07 05:36:08'),
(199, 49, 'logout', 'User logged out', '2026-05-07 05:37:15'),
(200, NULL, 'login', 'User logged in (trusted device) — 241-3-3333', '2026-05-07 05:37:24'),
(201, NULL, 'logout', 'User logged out', '2026-05-07 05:37:46'),
(202, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-05-07 05:38:02'),
(203, 46, 'logout', 'User logged out', '2026-05-07 05:38:07'),
(204, 48, 'login', 'User logged in (trusted device) — admin-0003', '2026-05-07 05:38:49'),
(205, 48, 'logout', 'User logged out', '2026-05-07 05:46:58'),
(206, NULL, 'login', 'User logged in (trusted device) — 241-3-3333', '2026-05-07 05:47:40'),
(207, NULL, 'logout', 'User logged out', '2026-05-07 05:48:29'),
(208, NULL, 'login', 'User logged in (trusted device) — 241-3-3333', '2026-05-07 05:49:01'),
(209, NULL, 'logout', 'User logged out', '2026-05-07 05:58:42'),
(210, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-05-07 05:58:52'),
(211, 46, 'logout', 'User logged out', '2026-05-07 06:01:29'),
(212, 47, 'login', 'User logged in (trusted device) — 241-5-1111', '2026-05-07 06:01:55'),
(213, 47, 'vote_cast', 'Voted in election: Student Council  — 2 position(s)', '2026-05-07 06:03:39'),
(214, 47, 'logout', 'User logged out', '2026-05-07 06:03:52'),
(215, 49, 'login', 'User logged in (trusted device) — 241-5-2222', '2026-05-07 06:04:05'),
(216, 49, 'vote_cast', 'Voted in election: Student Council  — 2 position(s)', '2026-05-07 06:04:14'),
(217, 49, 'logout', 'User logged out', '2026-05-07 06:05:05'),
(218, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-05-07 06:05:26'),
(219, 46, 'logout', 'User logged out', '2026-05-07 06:10:16'),
(220, 47, 'login', 'User logged in (trusted device) — 241-5-1111', '2026-05-07 06:10:34'),
(221, 47, 'logout', 'User logged out', '2026-05-07 06:11:46'),
(222, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-05-07 06:11:58'),
(223, 46, 'logout', 'User logged out', '2026-05-07 06:15:54'),
(224, 48, 'login', 'User logged in (trusted device) — admin-0003', '2026-05-07 06:50:06'),
(225, 48, 'logout', 'User logged out', '2026-05-07 06:53:25'),
(226, 47, 'login', 'User logged in (trusted device) — 241-5-1111', '2026-05-07 06:53:48'),
(227, 47, 'logout', 'User logged out', '2026-05-07 06:53:51'),
(228, NULL, 'login', 'User logged in (trusted device) — 241-3-3333', '2026-05-07 06:54:01'),
(229, NULL, 'logout', 'User logged out', '2026-05-07 07:00:44'),
(230, 48, 'login', 'User logged in (trusted device) — admin-0003', '2026-05-07 07:00:58'),
(231, 46, 'login', 'User logged in — admin-0002', '2026-06-27 15:45:22'),
(232, 46, 'logout', 'User logged out', '2026-06-27 15:49:11'),
(233, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-06-27 16:07:33'),
(234, 46, 'login', 'User logged in — admin-0002', '2026-06-28 13:16:19'),
(235, 49, 'login', 'User logged in — 241-5-2222', '2026-06-28 13:21:08'),
(236, 46, 'logout', 'User logged out', '2026-06-28 14:03:57'),
(237, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-06-28 14:04:10'),
(238, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-07-02 09:02:12'),
(239, 49, 'login', 'User logged in (trusted device) — 241-5-2222', '2026-07-02 09:20:14'),
(240, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-07-02 13:03:47'),
(241, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-07-02 17:38:14'),
(242, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-07-02 18:46:12'),
(243, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-07-03 12:20:05'),
(244, 46, 'login', 'User logged in (trusted device) — admin-0002', '2026-07-03 13:24:20');

-- --------------------------------------------------------

--
-- Table structure for table `trusted_devices`
--

CREATE TABLE `trusted_devices` (
  `user_id` int(11) NOT NULL,
  `token` varchar(255) NOT NULL,
  `expiry` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trusted_devices`
--

INSERT INTO `trusted_devices` (`user_id`, `token`, `expiry`, `created_at`) VALUES
(18, 'fzlqaa1eJNEj6wiJMVjEoVza4sKb6ULsoZt1LwIFNxU', '2026-06-06 00:59:44', '2026-05-02 14:54:49'),
(19, 'dSiEppuPmxzSP_10H7wpvXtKqtQn7ycqfODFwEKINYQ', '2026-06-05 12:21:07', '2026-05-01 20:17:56'),
(21, 'zyTtWpAAHn5xQYLzLY4u_5o-YjdTvRRrguCLrND3SLM', '2026-06-05 14:30:49', '2026-05-03 07:45:04'),
(23, 'GOn5eHBks7rnK0hQgdpACZW24vYVtcsW9A4dLzu4x9M', '2026-06-01 04:18:39', '2026-05-01 20:18:39'),
(24, 'eMVIlQLCPxSdAg1NyiifTcJ7tLCmdP6DGhhOJRLJy-c', '2026-06-04 16:59:55', '2026-05-02 15:37:11'),
(27, 'UN3dSXL8eWptGl4QLHQMs71VjPVlrgWhoXelG59DB7U', '2026-06-01 19:52:02', '2026-05-02 06:57:37'),
(28, 'kIRXJLRXetwrri7Vl6iY3Hd546eY-CnqImkgAZuIKoM', '2026-06-01 23:38:26', '2026-05-02 15:38:26'),
(31, 'emnoyN-_T-1tfJ2AjrTV-Ebh2i3OVqx3iJ4ymRWSS-M', '2026-06-04 15:52:51', '2026-05-05 07:52:51'),
(32, 'kEZPsGLGd55LPrvNjkwf6heXqUaycU5qKPzMk-pFXAY', '2026-06-04 15:51:30', '2026-05-05 07:51:30'),
(40, '0dwcunpu25rzyvHbJoAROELcBvzLbw8gtiYmNpfmmjA', '2026-06-06 01:00:16', '2026-05-06 14:21:25'),
(41, 'K-2kA2nptBv3DpGcX2PzRgVKIi-Eu8Ln6DJ1v6-sh9Y', '2026-06-05 22:29:58', '2026-05-06 14:29:58'),
(42, '-I3sEmcIdwmTqNkHp2tSY_EZCfdo_cLiEbeJkLfti-k', '2026-06-05 23:11:45', '2026-05-06 14:38:22'),
(43, '-S4T7jTdC41q11pkBGD8F2mGsRF62FD5RGimW-md4u4', '2026-06-05 23:55:39', '2026-05-06 15:55:39'),
(44, 'JNUH2eLlh_XtpKwrlrW_bChdK0Qsram_gIgqZ722R54', '2026-06-05 23:59:03', '2026-05-06 15:59:03'),
(46, '7FoavbgfwTiUFJEJzmqcP8_Kwne2ZhZJAmfjvANxxzI', '2026-07-28 21:16:19', '2026-05-06 17:57:07'),
(47, 'GaszsS_w4zE-mcQSgF8ei3wcK_IszMJ-6CgvmY3nAgE', '2026-06-06 12:57:15', '2026-05-07 04:57:15'),
(48, 'Z-Hu2SpG3odEBYb1bripykuwR0ljs_Pxrvx1alxnXno', '2026-06-06 13:29:57', '2026-05-07 05:29:57'),
(49, 'SFA3YAjJkNh35Y_M5nT0TN-0fb1zLWOGExQGeh8VsL8', '2026-07-28 21:21:08', '2026-05-07 05:36:08'),
(50, 'FARi4AJXzzZlmEg-AGNrNkDPBlXbqY5KMZC5U2X8R6Y', '2026-06-06 13:33:56', '2026-05-07 05:33:56');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `student_id` varchar(20) DEFAULT NULL,
  `firstname` varchar(50) NOT NULL,
  `middlename` varchar(50) DEFAULT NULL,
  `surname` varchar(50) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('superadmin','admin','voter') NOT NULL,
  `has_voted` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_approved` tinyint(1) DEFAULT 0,
  `college_id` int(11) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `is_archived` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `student_id`, `firstname`, `middlename`, `surname`, `email`, `password`, `role`, `has_voted`, `created_at`, `is_approved`, `college_id`, `is_active`, `is_archived`) VALUES
(18, 'SUPER001', 'Super', 'Nomo', 'Admin', 'jamesmatthewalmonte45@gmail.com', 'scrypt:32768:8:1$9BgRmmpAg8ejyM4A$d221896d3e644d6721b01c6ddb3aa838d92e00dd9e81e4e183c98839c1a737fdadb8534b8c91575ab5cadb481aa974e87f71b679bc56a8d8a122193663fde670', 'superadmin', 0, '2026-03-29 09:48:11', 1, NULL, 1, 0),
(46, 'admin-0002', 'Cyrus James', 'Nomo', 'Matienzo', 'cjmatienzo2@gmail.com', 'scrypt:32768:8:1$J3NeT1A2dleQQMsa$844b88020744d1c691767628fc3684295f89563b14467dbabd458973d407a372aa908a83ae7add0607373d6ac802a9b6619d851ba47e2df8f4f058df3b7c3871', 'admin', 0, '2026-05-06 17:34:40', 1, 5, 1, 0),
(47, '241-5-1111', 'James Matthew', 'Montenegro', 'Almonte', 'remremremremrem125@gmail.com', 'scrypt:32768:8:1$WxBfGAWc7pBfsD1M$13ea3e99cab75e2f60c95fd0629f86f0ad99204156b573bf756b75b58f8a26ecf9ddd32ca81d238490e1ba011f13022e4a2c49e2d7561fad12046236f8a23add', 'voter', 0, '2026-05-07 04:56:10', 1, 5, 1, 0),
(48, 'admin-0003', 'James Matthew', 'Montenegro', 'Almonte', 'rarararadrem@gmail.com', 'scrypt:32768:8:1$M7srGC8qiKi4Z5RH$02237d5519d7de59b41ddc27f854d4f85dc43336f59e277f5404b075a1a38cb0764186148bb30537dffc51298cdf4b22631d3f6d238e49f70d01f9668b0c3595', 'admin', 0, '2026-05-07 05:01:06', 1, 3, 1, 0),
(49, '241-5-2222', 'Justin', 'Dion', 'Salaveria', 'cjhanmatienzo@gmail.com', 'scrypt:32768:8:1$gzSARPYDQ40Ikapa$6929b2863b299cf6966b1da4d3299c9c61e439175274cf0024e4dc5bdcf518ec8edb51ef3c21163c8ef72e5e1dcfbda8f2c484bf420267d82869a6c5cbedfd38', 'voter', 0, '2026-05-07 05:28:01', 1, 5, 1, 0),
(51, 'A26-0000', 'Justin Dion', 'Bibon', 'Salaveria', 'justindion180@gmail.com', 'scrypt:32768:8:1$U6dSaNNxSJAP6jNi$9af5ecf8f5d6c73f8a6f923e3036ab9d7515f6f4f13246f7085402b3d56d83eca2a3f9171e15154030381b2cbc8292d90b1d94444dbd8a05ba6e3739fe0c38d7', 'superadmin', 0, '2026-07-08 12:27:15', 1, NULL, 1, 0),
(52, 'A26-0002', 'Asia', 'Pas', 'Asis', 'cjmatienzo@gmail.com', 'scrypt:32768:8:1$RYL1pIVUdp3rZaCA$a359dc24553d7fe78a9d10cd8e4059a3d487db04b3861b14fa35f4aeb294bec062fa11a73db3af5cbeb787ee6df8b767dd411bf543689201eb87625c92432fe8', 'admin', 0, '2026-07-08 12:28:54', 1, 4, 1, 0),
(53, 'S26-0001', 'Cj', 'Han Nomo', 'Matienzo', 'arnzo@gmail.com', 'scrypt:32768:8:1$dFITogN0T6hF8SP3$e306c733c20cbb45a0c5543945c3d6296d0d691feee5e8ad3fb9c4e834ba1238880607dae031965aae53c58b8d3326a2eb99a8c2929639885757c04d647a23c1', 'voter', 0, '2026-07-09 14:03:58', 1, NULL, 1, 0),
(54, 'S26-0002', 'sda', 'adas', 'adas', 'adaa@gmail.com', 'scrypt:32768:8:1$1dIUasmRm8tLmqXk$4702f83006c70d1ead1a2da794c29ff5587135f3840e9724908a60a891d7e3a666711bd31ae08a4f5657d2b1aecaa8cde80269e31e94d580a394b1d8a8768822', 'voter', 0, '2026-07-09 14:07:41', 1, NULL, 1, 0),
(55, 'A26-0003', 'Cj', 'No', 'Ma', 'ahahazo@gmail.com', 'scrypt:32768:8:1$TwOPc1EbmLtEtFyr$23a65834cc02c0e65746b24dc8091dbe97e6a0b9309d9b7f346da22be34ad3a1254f3a7960d06a2e000d4c945f097be0615c842bf48254af31bb3c2b8753b437', 'admin', 0, '2026-07-10 04:11:07', 1, NULL, 1, 0),
(56, 'A26-0004', 'Cj', 'Nio', 'Matien', 'cjhanmao@gmail.com', 'scrypt:32768:8:1$43InwXqQdiq1VlFA$c4d8fa49ad302e7354c96e8f4949db0469ecddc84ff1172860b26801183daf4a8625604ff66f4a49098298236db02279c919f5cef77261fea1d8a8f602f49194', 'admin', 0, '2026-07-10 08:02:12', 1, NULL, 1, 0),
(57, 'A26-0005', 'Sd', 'Dada', 'Dasdd', 'asdadaf@gmail.com', 'scrypt:32768:8:1$0LHR5qhRHQgCsRVN$6aa0fa32468127600fb7ca9214b2b15c35c52654b37a8a82b95700d98ae47211277bf7397d399ddb2da82b4462e240489a4cd820707c4428721864e49661a319', 'admin', 0, '2026-07-10 13:50:30', 1, 5, 1, 0),
(58, 'A26-0006', 'Asdad', 'Adada', 'Adadada', 'ahdiabdibavd@gmail.com', 'scrypt:32768:8:1$nl7Ng3VedtiYNSBX$205f1b97fea21943edea2f4a9bf4ae741051503632185a5cc86e626c95bf3494fe15f20ef6a65ae0d89c4de525a429337a50954287b840dc82f63a6c6b720a13', 'admin', 0, '2026-07-10 13:51:23', 1, 3, 1, 0),
(59, 'S26-0003', 'Joan', 'Sidamon', 'Gutiza', 'jgutiza30@gmail.com', 'scrypt:32768:8:1$c7uMHbdeylLtU4Og$38217c4f39bcc2f413c6968c354831350c560c14ed1f06ecbd38f41ab6353f9c3788b4fc27b2ebe38ff339ed0efce2ba512410f54046dc886e9e075e0cfae488', 'voter', 0, '2026-07-10 18:51:22', 1, NULL, 1, 0),
(60, 'S26-0004', 'Onin', '', 'Napiza', 'oninnapiza4@gmail.com', 'scrypt:32768:8:1$gnYSCcdMvUI2eKfF$6c983d9c32b8ea503d91cca1b56fb9db5c2e120fbee8caac7012bdc9fde2df25763bf35f21feaa6f25b951d454c829847978f5d11a4cda9eeb122adfdf550a0f', 'voter', 0, '2026-07-10 20:13:46', 1, NULL, 1, 0),
(61, 'S26-0005', 'Xzon', '', 'Guinto', 'gutizaaudie1@gmail.com', 'scrypt:32768:8:1$ahrMDxBn8JYxwd6O$33e2b3a7547d7601792dc9e5317263223f47ff1e19d9407ae7aa596d3d5ed6381fe51141699a2b0f77466ee9c4c968503e1f51bc1c2c255b0848e6557e86c437', 'voter', 0, '2026-07-10 20:31:33', 1, NULL, 1, 0),
(62, 'S26-0006', 'Xzone', 'Nazarene', 'Ginto', 'xzoneginto@gmail.com', 'scrypt:32768:8:1$AU0FoDxgRnALZlsu$60ee7a7bfa73cfa4987548b0f46498d6f38b581f1724e58471b4b1a276f1effea4bcaa64b7b9c3020830846efb932c2333cafaab2b3981504fda451b50ceedd9', 'voter', 0, '2026-07-11 04:18:41', 1, NULL, 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `votes`
--

CREATE TABLE `votes` (
  `id` int(11) NOT NULL,
  `voter_id` int(11) NOT NULL,
  `election_id` int(11) NOT NULL,
  `position_id` int(11) NOT NULL,
  `candidate_id` int(11) NOT NULL,
  `cast_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `college_id` (`college_id`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `candidates`
--
ALTER TABLE `candidates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `position_id` (`position_id`),
  ADD KEY `candidates_college_fk` (`college_id`);

--
-- Indexes for table `colleges`
--
ALTER TABLE `colleges`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `elections`
--
ALTER TABLE `elections`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `elections_college_fk` (`college_id`);

--
-- Indexes for table `otp_codes`
--
ALTER TABLE `otp_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `positions`
--
ALTER TABLE `positions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `election_id` (`election_id`),
  ADD KEY `positions_college_fk` (`college_id`);

--
-- Indexes for table `system_logs`
--
ALTER TABLE `system_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `trusted_devices`
--
ALTER TABLE `trusted_devices`
  ADD PRIMARY KEY (`user_id`),
  ADD KEY `idx_user_token` (`user_id`,`token`),
  ADD KEY `idx_expiry` (`expiry`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_id` (`student_id`),
  ADD KEY `users_college_fk` (`college_id`);

--
-- Indexes for table `votes`
--
ALTER TABLE `votes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_vote` (`voter_id`,`election_id`,`position_id`),
  ADD KEY `election_id` (`election_id`),
  ADD KEY `position_id` (`position_id`),
  ADD KEY `candidate_id` (`candidate_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `candidates`
--
ALTER TABLE `candidates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=47;

--
-- AUTO_INCREMENT for table `colleges`
--
ALTER TABLE `colleges`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `elections`
--
ALTER TABLE `elections`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `otp_codes`
--
ALTER TABLE `otp_codes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `positions`
--
ALTER TABLE `positions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `system_logs`
--
ALTER TABLE `system_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=245;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=63;

--
-- AUTO_INCREMENT for table `votes`
--
ALTER TABLE `votes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `announcements`
--
ALTER TABLE `announcements`
  ADD CONSTRAINT `fk_ann_college` FOREIGN KEY (`college_id`) REFERENCES `colleges` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `candidates`
--
ALTER TABLE `candidates`
  ADD CONSTRAINT `candidates_college_fk` FOREIGN KEY (`college_id`) REFERENCES `colleges` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `candidates_ibfk_1` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `elections`
--
ALTER TABLE `elections`
  ADD CONSTRAINT `elections_college_fk` FOREIGN KEY (`college_id`) REFERENCES `colleges` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `elections_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `otp_codes`
--
ALTER TABLE `otp_codes`
  ADD CONSTRAINT `otp_codes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `positions`
--
ALTER TABLE `positions`
  ADD CONSTRAINT `positions_college_fk` FOREIGN KEY (`college_id`) REFERENCES `colleges` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `positions_ibfk_1` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `system_logs`
--
ALTER TABLE `system_logs`
  ADD CONSTRAINT `system_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_college_fk` FOREIGN KEY (`college_id`) REFERENCES `colleges` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `votes`
--
ALTER TABLE `votes`
  ADD CONSTRAINT `votes_ibfk_1` FOREIGN KEY (`voter_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `votes_ibfk_2` FOREIGN KEY (`election_id`) REFERENCES `elections` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `votes_ibfk_3` FOREIGN KEY (`position_id`) REFERENCES `positions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `votes_ibfk_4` FOREIGN KEY (`candidate_id`) REFERENCES `candidates` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
