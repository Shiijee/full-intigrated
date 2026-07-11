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
-- Database: `db_portal`
--

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `role` enum('superadmin','admin','teacher','student') NOT NULL DEFAULT 'student',
  `external_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `full_name`, `email`, `role`, `external_id`) VALUES
(5, 'SUPER001', 'scrypt:32768:8:1$9BgRmmpAg8ejyM4A$d221896d3e644d6721b01c6ddb3aa838d92e00dd9e81e4e183c98839c1a737fdadb8534b8c91575ab5cadb481aa974e87f71b679bc56a8d8a122193663fde670', 'Super Nomo Admin', 'jamesmatthewalmonte45@gmail.com', 'superadmin', 'SUPER001'),
(14, 'A26-0000', 'scrypt:32768:8:1$U6dSaNNxSJAP6jNi$9af5ecf8f5d6c73f8a6f923e3036ab9d7515f6f4f13246f7085402b3d56d83eca2a3f9171e15154030381b2cbc8292d90b1d94444dbd8a05ba6e3739fe0c38d7', 'Justin Dion Bibon Salaveria', 'justindion180@gmail.com', 'superadmin', 'A26-0000'),
(15, 'A26-0001', 'scrypt:32768:8:1$ciXvs9sDpCRQz4Bq$3a5f99aa275e86a4daa3b4f249c97750775d8d2aa85307e6c3b9a9cc044fed1a02234c05ac1864b9add5d7629e8c2c3266e6e2cdfc520234ae3c12459962e8a6', 'Tyrael None Gonzalvo', 'gonzalvo.tyrael@gmail.com', 'admin', 'A26-0001'),
(28, 'A26-0002', 'scrypt:32768:8:1$tx8oNiwZ6m5Fs44U$91cf5fc9774a082ecfb6b59896ce0f35fbf6e6ea79cc095314d762120bc11da4f717d28772083d057adbe501338af0f0478492ff4f4af7afea4fa0430f51501e', 'Asia Pas Asis', 'cjmatienzo@gmail.com', 'admin', 'A26-0002'),
(29, 'S26-0001', 'scrypt:32768:8:1$btOJWsDx4e913sz4$85d99fb6cdfb128e41e66e340b62a610f51058bd8d7fab1c020a7fc74a947871f6bf0d473d564221b9e67ebec88aeeceb42f6bf34b10de8a1fa18317af21a5ec', 'Cj Han Nomo Matienzo', 'arnzo@gmail.com', 'student', 'S26-0001'),
(30, 'S26-0002', 'scrypt:32768:8:1$hL1vRMxy8N5ld4yz$2387ffb70f1f5b0b183857a539a3f6e6c1bf77392da58113787ea89be90cb5c4e349b5f838b593f0decede41ed79e6fcc500a6b301ddd96bac92689f723f8448', 'sda adas adas', 'adaa@gmail.com', 'student', 'S26-0002'),
(31, 'T26-0001', 'scrypt:32768:8:1$qsRAvMILrgWA8mT2$2c1aad518a32747ce992c894a7239b892f35a3a6270e494e499a0f77e8458243fa2bbc4bfe4c9cc1e6a4f0f6d82656b34be0beb471be71b7102599c4d0178914', 'Cj Han Nomo Matienzo', 'cjhanenzo@gmail.com', 'teacher', 'T26-0001'),
(32, 'T26-0002', 'scrypt:32768:8:1$jaxHiywsiyXfT4Di$a3fb77b3872acf1522f820b883cd5d24fca46957f3bf10d7a526cf3a4c067f1c12c7d6c55f2916b7b73d8639f6496455679b248f7f424608587c772e1b59fde1', 'Cj Nomo Matienzo', 'cjhanmanzo@gmail.com', 'teacher', 'T26-0002'),
(33, 'T26-0003', 'scrypt:32768:8:1$4ieHgDWKdVnR9uuY$30dc54a260d9cfe93942d152fda8b5706e1167c96965a300f6fd783de1e84b9f0d1d2985118b8aa77f646620c6d3069e53b898bc8d9d014039fb3f92ef5d9f88', 'Cj No Maenzo', 'cjhano@gmail.com', 'teacher', 'T26-0003'),
(34, 'A26-0003', 'scrypt:32768:8:1$aFE0XdBhnS5rbEjc$d00df7f6168a446363a46ff6d3921ed5757e9fc2edad4fbe22d42bc66038525178d6e16d616e869c7e40bb7103d2dc808d97a56c4bd3034eedc1f3051eb3e967', 'Cj No Ma', 'ahahazo@gmail.com', 'admin', 'A26-0003'),
(35, 'A26-0004', 'scrypt:32768:8:1$evfSbhx6ZbhO7etE$b6ecae99a0a541746f5bc8109a3bd7a56aa87080af8a66e0a5ee3d025ae1f2be934ae6e53157cbd300a824d5b3fc439202d57437ca714c6ee09eb7da90d81a57', 'Cj  Nio Matien', 'cjhanmao@gmail.com', 'admin', 'A26-0004'),
(36, 'A26-0005', 'scrypt:32768:8:1$2HXDgORNLDH80NUi$a34321d473eb1cefb2de1b9d7a41ba7b112e4b6e907784bbd814d7994142ce88a473c0e8f02df0165949a5f9b3fee67ea2ea655a3dab784c7cd3bd34bf0858c4', 'Sd Dada Dasdd', 'asdadaf@gmail.com', 'admin', 'A26-0005'),
(37, 'A26-0006', 'scrypt:32768:8:1$Sc3lHd1DR0xHGuRt$17bdc84622f1507d2c3695a144e00a8dc32eb7cdc37c6b9214257a68542011d97232e6176e71e6454d36402b389706ddc00f9d9a88b64b34296d70e783785f40', 'Asdad Adada Adadada', 'ahdiabdibavd@gmail.com', 'admin', 'A26-0006'),
(38, 'S26-0003', 'scrypt:32768:8:1$jUsvMxk5XAvdOewr$5adee13a0de5a48c32a0fca399270adc377942afdcbff0ba5920a12639affe6cf490a9962f0609b1415e6f0d6bce484e7edcacf4f17270a6623e808eb75bcdd8', 'Joan  Sidamon  Gutiza', 'jgutiza30@gmail.com', 'student', 'S26-0003'),
(39, 'S26-0004', 'scrypt:32768:8:1$JJBkWHFEDBpn9sXQ$d35332a31bfe4fdb94b37ab0d66ef656f340eaabd8bc21932d12631d7187e54006644762223fc677f98c8f685d3b8f3589225c4e808be83d16a4f2c96fc4e556', 'Onin Napiza', 'oninnapiza4@gmail.com', 'student', 'S26-0004'),
(40, 'S26-0005', 'scrypt:32768:8:1$Xvowy6UUQllLmPzd$e40815dd575d842432aca9ce44524616a8ffa736106049a3c6fc26cec145ef5624f5bd2b67da399bde7f1a6b1c7ca4c612cd7376be47d4a3c81656d654de5fab', 'Xzon Guinto', 'gutizaaudie1@gmail.com', 'student', 'S26-0005'),
(41, 'S26-0006', 'scrypt:32768:8:1$p6EIYXdEwIrlS64u$56da848583cd79f20a8bc158a67cabf8ecfa9a560522a0433091c5e90f2522c17d69b3886f0bc0e785028353b33048724ef2edc96a1c4de1363079788be7befc', 'Xzone Nazarene Ginto', 'xzoneginto@gmail.com', 'student', 'S26-0006'),
(42, 'T26-0004', 'scrypt:32768:8:1$suKvI7JxJ2FXhtB1$f40afacc0d1e3b43fc9f70ba69d580788fa03e54b207cf0c96ca3dd6bc438d7b9fa7c4e9e8174ce3d5653d201ea088458906109da94e9894229216f389c79b0f', 'John Andrei Sidamon  Napiza', 'johnandreisidamongutiza@gmail.com', 'teacher', 'T26-0004'),
(43, 'T26-0005', 'scrypt:32768:8:1$t2hpju8pDp7p1st3$5bef38bc03a93a78d004b7588175d5909db1f1e964f6f69617f6f14a3472ecc11a5e0bace8a10340a6039f40617e68679fced93bdfa14a44f2622da9d457ab87', 'John Andrei gutiza', 'johnandreisidamongutizaa@gmail.com', 'teacher', 'T26-0005'),
(44, 'T26-0006', 'scrypt:32768:8:1$X1C1voM3BaKXNMHa$ca8cd2bfcf9c7439beaa415b5834a9feb8b006bdea953c704dbf6dcdab3232971a7f9010bd015e119c059199ced0730a0bc6dd775b333b4613b994d549e4ad59', 'John Andrei gutizas', 'jgutiza301@gmail.com', 'teacher', 'T26-0006'),
(45, 'T26-0007', 'scrypt:32768:8:1$OX4OEgucgQRk3yZG$61e995740c603829a993fff30421783507d4d80494673f1a954386e3e2918ed36ee3f6daae97c0f6c110583c4c736768ed925ffc44c7c0de43e9181149603dd1', 'Onin napizas', 'oninnapiza41@gmail.com', 'teacher', 'T26-0007');

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
