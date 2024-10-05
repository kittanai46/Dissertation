-- MySQL dump 10.13  Distrib 8.0.38, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: mysql_nodejs
-- ------------------------------------------------------
-- Server version	9.0.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `course_code` varchar(20) NOT NULL,
  `section` int NOT NULL,
  `student_id` varchar(20) NOT NULL,
  `date` date NOT NULL,
  `status` enum('present','absent','late') NOT NULL,
  `check_in_time` time DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_attendance` (`course_code`,`section`,`student_id`,`date`)
) ENGINE=InnoDB AUTO_INCREMENT=184 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
INSERT INTO `attendance` VALUES (153,'226482',1,'64020934','2024-09-15','present','15:14:14'),(154,'226482',1,'64022222','2024-09-15','late','15:16:15'),(155,'226482',1,'64123456','2024-09-15','absent','15:20:33'),(181,'226482',1,'64020934','2024-09-16','present','16:20:52'),(182,'226482',1,'64022222','2024-09-16','late','16:21:19'),(183,'226482',1,'64123456','2024-09-16','absent','16:25:45');
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_rules`
--

DROP TABLE IF EXISTS `attendance_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_rules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `course_code` varchar(20) NOT NULL,
  `section` int NOT NULL,
  `date` date NOT NULL,
  `present_until` time NOT NULL,
  `late_until` time NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_rule` (`course_code`,`section`,`date`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_rules`
--

LOCK TABLES `attendance_rules` WRITE;
/*!40000 ALTER TABLE `attendance_rules` DISABLE KEYS */;
INSERT INTO `attendance_rules` VALUES (15,'226482',1,'2024-09-16','16:21:00','16:22:00'),(16,'226482',1,'2024-09-15','15:15:00','15:20:00');
/*!40000 ALTER TABLE `attendance_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_teachers`
--

DROP TABLE IF EXISTS `course_teachers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_teachers` (
  `course_code` varchar(20) NOT NULL,
  `section` int NOT NULL,
  `teacher_id` varchar(30) NOT NULL,
  PRIMARY KEY (`course_code`,`section`,`teacher_id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `course_teachers_ibfk_1` FOREIGN KEY (`course_code`, `section`) REFERENCES `courses` (`course_code`, `section`) ON DELETE CASCADE,
  CONSTRAINT `course_teachers_ibfk_2` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id_number`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_teachers`
--

LOCK TABLES `course_teachers` WRITE;
/*!40000 ALTER TABLE `course_teachers` DISABLE KEYS */;
INSERT INTO `course_teachers` VALUES ('1113',2,'11112222'),('1114',1,'11112222'),('1111',1,'11223344'),('1112',1,'11223344'),('1113',2,'11223344'),('1234',3,'11223344'),('226482',1,'11223344');
/*!40000 ALTER TABLE `course_teachers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `courses` (
  `course_id` int NOT NULL AUTO_INCREMENT,
  `course_code` varchar(20) NOT NULL,
  `course_name` varchar(255) NOT NULL,
  `section` int NOT NULL,
  `year` int NOT NULL,
  `major` int NOT NULL,
  `minor` int NOT NULL,
  PRIMARY KEY (`course_id`),
  UNIQUE KEY `uc_course_code_section` (`course_code`,`section`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES (4,'226482','ภาษาไทย',1,64,226,4821),(8,'1234','ภาษาไทย',2,64,0,0),(9,'1234','ภาษาไทย',3,64,0,0),(10,'1111','แคลคูลัส',1,65,0,0),(11,'1112','หลักการอิเล็กทรอนิกส์',1,66,0,0),(12,'1113','โครงสร้างข้อมูล',2,64,0,0),(15,'1114','โครงงานวิศวกรรมคอมพิวเตอร์',1,64,0,0);
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `enrollments`
--

DROP TABLE IF EXISTS `enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `enrollments` (
  `enrollment_id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(30) DEFAULT NULL,
  `course_code` varchar(20) DEFAULT NULL,
  `section` int DEFAULT NULL,
  PRIMARY KEY (`enrollment_id`),
  KEY `fk_enrollment_course` (`course_code`,`section`),
  KEY `enrollments_ibfk_1` (`student_id`),
  CONSTRAINT `enrollments_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id_number`) ON DELETE CASCADE,
  CONSTRAINT `fk_enrollment_course` FOREIGN KEY (`course_code`, `section`) REFERENCES `courses` (`course_code`, `section`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enrollments`
--

LOCK TABLES `enrollments` WRITE;
/*!40000 ALTER TABLE `enrollments` DISABLE KEYS */;
INSERT INTO `enrollments` VALUES (1,'64020934','226482',1),(2,'64022222','226482',1),(3,'64020934','1234',2),(4,'64123456','226482',1);
/*!40000 ALTER TABLE `enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `log_attendance`
--

DROP TABLE IF EXISTS `log_attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `log_attendance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_number` varchar(30) NOT NULL,
  `major` int DEFAULT NULL,
  `minor` int DEFAULT NULL,
  `schedule_date` date DEFAULT NULL,
  `schedule_time` time DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_attendance`
--

LOCK TABLES `log_attendance` WRITE;
/*!40000 ALTER TABLE `log_attendance` DISABLE KEYS */;
INSERT INTO `log_attendance` VALUES (25,'64020934',226,4821,'2024-09-16','01:58:34'),(26,'64022222',226,4821,'2024-09-16','02:41:48'),(27,'64022222',226,4821,'2024-09-16','03:50:30'),(28,'64020934',226,4821,'2024-09-16','03:50:30'),(29,'64020934',226,4821,'2024-09-16','14:52:35'),(30,'64022222',226,4821,'2024-09-16','14:53:23'),(31,'64123456',226,4821,'2024-09-16','14:58:55'),(32,'64022222',226,4821,'2024-09-16','15:01:05'),(33,'64123456',226,4821,'2024-09-16','15:07:32'),(34,'64022222',226,4821,'2024-09-16','15:10:25'),(35,'64020934',226,4821,'2024-09-16','15:47:22'),(36,'64020934',226,4821,'2024-09-16','15:47:22'),(37,'64020934',226,4821,'2024-09-16','15:47:22'),(38,'64022222',226,4821,'2024-09-16','15:47:30'),(39,'64020934',226,4821,'2024-09-16','15:48:04'),(40,'64123456',226,4821,'2024-09-16','15:49:31'),(41,'64022222',226,4821,'2024-09-16','15:52:37'),(42,'64020934',226,4821,'2024-09-16','15:55:07'),(43,'64020934',226,4821,'2024-09-16','15:55:34'),(44,'64020934',226,4821,'2024-09-16','16:02:15'),(45,'64022222',226,4821,'2024-09-16','16:02:57'),(46,'64022222',226,4821,'2024-09-16','16:03:45'),(47,'64020934',226,4821,'2024-09-16','16:04:01'),(48,'64020934',226,4821,'2024-09-16','16:20:52'),(49,'64022222',226,4821,'2024-09-16','16:21:19'),(50,'64123456',226,4821,'2024-09-16','16:25:45');
/*!40000 ALTER TABLE `log_attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `teacher_id` int NOT NULL,
  `course_code` varchar(20) NOT NULL,
  `section` int NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (1,11223344,'1111',1,'สวัสดี\r\n','2024-09-15 21:01:38'),(2,11223344,'226482',1,'สวัสดี\r\n','2024-09-15 21:02:08'),(3,11223344,'1234',3,'สวัสดี sec3','2024-09-15 21:17:45');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_number` varchar(30) NOT NULL,
  `enrollment_year` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_number` (`id_number`),
  KEY `idx_student_id_number` (`id_number`),
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`id_number`) REFERENCES `users` (`id_number`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES (1,'64022222',64),(2,'64020934',64),(3,'64123456',64);
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teacher_schedule_images`
--

DROP TABLE IF EXISTS `teacher_schedule_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teacher_schedule_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `teacher_id` varchar(30) DEFAULT NULL,
  `schedule_image_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `teacher_id` (`teacher_id`),
  CONSTRAINT `teacher_schedule_images_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id_number`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacher_schedule_images`
--

LOCK TABLES `teacher_schedule_images` WRITE;
/*!40000 ALTER TABLE `teacher_schedule_images` DISABLE KEYS */;
INSERT INTO `teacher_schedule_images` VALUES (1,'11112222','/image/schedules/11112222.png'),(2,'11223344','/image/schedules/11223344.png'),(3,'12121212','/image/schedules/12121212.png');
/*!40000 ALTER TABLE `teacher_schedule_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `id_number` varchar(30) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('teacher','student') NOT NULL,
  UNIQUE KEY `id_number` (`id_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('กันตพงศ์','วิชาแหลม','11112222','$2b$12$MyVxszICHKmAzhUZlFqYj.0Szck3vJwaGU/jROepqWE5f7pWQwn5a','teacher'),('Makk','Noy','11223344','$2b$12$GVOYczNipAxe8xKjQrpCGuBdJ884M4dgZGxK.YCTMq8XLzkewkKgK','teacher'),('อภิภู','ส่งศรี','12121212','$2b$12$HCb2NsTBJSPBDHi9p/VTEut2yDmt1.9DSYXTcDRGwYlP8pW2QC3S6','teacher'),('Kanta','Wicha','64020934','$2b$12$0fHGTX/vl4npqDIBzfYRNOny72YFoTMx8eqTiDKWl8M2cXuRLiYDO','student'),('Mak','Mee','64022222','$2b$12$pmZufll6vHa2cKvsQkzjQOAGIXOkOnXOfIame.CQB4zXfjzpaM/HK','student'),('Kata','Kana','64123456','$2b$12$r9hrDRCXorAmELZH.TnOduyTUEvGojSCCDPHOFdBvco./9qH.AKgO','student');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-09-16 16:33:30
