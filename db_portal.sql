-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 09, 2026 at 02:09 PM
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
-- Database: `db_portal`
--

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_general_ci NOT NULL,
  `full_name` varchar(100) COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `role` enum('superadmin','admin','teacher','student') COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'student',
  `external_id` varchar(50) COLLATE utf8mb4_general_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `full_name`, `email`, `role`, `external_id`) VALUES
(5, 'SUPER001', 'scrypt:32768:8:1$9BgRmmpAg8ejyM4A$d221896d3e644d6721b01c6ddb3aa838d92e00dd9e81e4e183c98839c1a737fdadb8534b8c91575ab5cadb481aa974e87f71b679bc56a8d8a122193663fde670', 'Super Nomo Admin', 'jamesmatthewalmonte45@gmail.com', 'superadmin', 'SUPER001'),
(14, 'A26-0000', 'scrypt:32768:8:1$U6dSaNNxSJAP6jNi$9af5ecf8f5d6c73f8a6f923e3036ab9d7515f6f4f13246f7085402b3d56d83eca2a3f9171e15154030381b2cbc8292d90b1d94444dbd8a05ba6e3739fe0c38d7', 'Justin Dion Bibon Salaveria', 'justindion180@gmail.com', 'superadmin', 'A26-0000'),
(15, 'A26-0001', 'scrypt:32768:8:1$ciXvs9sDpCRQz4Bq$3a5f99aa275e86a4daa3b4f249c97750775d8d2aa85307e6c3b9a9cc044fed1a02234c05ac1864b9add5d7629e8c2c3266e6e2cdfc520234ae3c12459962e8a6', 'Tyrael None Gonzalvo', 'gonzalvo.tyrael@gmail.com', 'admin', 'A26-0001'),
(28, 'T26-0001', 'scrypt:32768:8:1$1G7AGCwugcptuSaS$b4ed3caa069fa241a2a04428a4d1335df988af51f32aad4455c33e9387bbf06b2342cca1f435df1ad691353addbbf72031aec5862f8d3986946c66980eafe37b', 'Justin Dion Bibon Salaveria', 'justindionsalaveria@gmail.com', 'teacher', 'T26-0001'),
(29, 'S26-0001', 'scrypt:32768:8:1$xZbKhkfsrY5YBIxS$aded984e70e5bab56abd2e462aa3c80c5465a3b3cbb0dfbf18ba9e2854b3f6496a5b7c7429129db1144db8fffea6b126a062bf36e456fe1f62266db7cf8a76bd', 'Justin Dion Bibon Salaveria', 'ninio123@gmail.com', 'student', 'S26-0001'),
(30, 'S26-0002', 'scrypt:32768:8:1$dd7lbPQvr4P7oFEc$cbfcf5e4bb5319291760da9a37e678ed2c83742fde565b52afb67f2bb6dbf27937868427116bd2becc12aa0af8125f28de7c380dd6857f25daebca8b79615ae4', 'James Montenegro Almonte', 'jinggoy123@gmail.com', 'student', 'S26-0002');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
