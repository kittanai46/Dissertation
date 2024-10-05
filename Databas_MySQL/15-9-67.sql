-- MySQL dump 10.13  Distrib 8.0.38, for Win64 (x86_64)
--
-- Host: localhost    Database: mysql_nodejs
-- ------------------------------------------------------
-- Server version	8.0.39

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
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_attendance` (`course_code`,`section`,`student_id`,`date`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
INSERT INTO `attendance` VALUES (1,'1234',1,'64020934','1222-12-11','present');
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_rules`
--

LOCK TABLES `attendance_rules` WRITE;
/*!40000 ALTER TABLE `attendance_rules` DISABLE KEYS */;
INSERT INTO `attendance_rules` VALUES (1,'1234',1,'2567-09-08','18:00:00','18:30:00'),(2,'1234',1,'1222-12-12','11:11:00','12:22:00'),(3,'1234',1,'2222-02-12','22:22:00','23:23:00');
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
INSERT INTO `course_teachers` VALUES ('1113',2,'11112222'),('1114',1,'11112222'),('1111',1,'11223344'),('1112',1,'11223344'),('1113',2,'11223344'),('1234',1,'11223344'),('1234',2,'11223344'),('1234',3,'11223344');
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
  PRIMARY KEY (`course_id`),
  UNIQUE KEY `uc_course_code_section` (`course_code`,`section`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES (4,'1234','Math',1,64),(8,'1234','Math',2,64),(9,'1234','Math',3,64),(10,'1111','ICT',1,65),(11,'1112','ICT',1,66),(12,'1113','ICT',2,64),(15,'1114','ICT',1,64);
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
  `student_id` varchar(20) DEFAULT NULL,
  `course_code` varchar(20) DEFAULT NULL,
  `section` int DEFAULT NULL,
  PRIMARY KEY (`enrollment_id`),
  KEY `student_id` (`student_id`),
  KEY `fk_enrollment_course` (`course_code`,`section`),
  CONSTRAINT `enrollments_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id_number`) ON DELETE CASCADE,
  CONSTRAINT `fk_enrollment_course` FOREIGN KEY (`course_code`, `section`) REFERENCES `courses` (`course_code`, `section`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enrollments`
--

LOCK TABLES `enrollments` WRITE;
/*!40000 ALTER TABLE `enrollments` DISABLE KEYS */;
INSERT INTO `enrollments` VALUES (1,'64020934','1234',1),(2,'64022222','1234',1),(3,'64020934','1234',2);
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_attendance`
--

LOCK TABLES `log_attendance` WRITE;
/*!40000 ALTER TABLE `log_attendance` DISABLE KEYS */;
INSERT INTO `log_attendance` VALUES (1,'11112222',1234,5678,'2024-09-15','01:26:12'),(2,'11112222',1234,5678,'2024-09-15','01:26:24'),(3,'11112222',1234,5678,'2024-09-15','01:26:29'),(4,'11112222',226,4835,'2024-09-15','01:46:06'),(5,'11112222',226,4835,'2024-09-15','01:48:35'),(6,'11223344',226,4835,'2024-09-15','01:49:00');
/*!40000 ALTER TABLE `log_attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `students` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_number` varchar(20) NOT NULL,
  `enrollment_year` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_number` (`id_number`),
  KEY `idx_student_id_number` (`id_number`),
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`id_number`) REFERENCES `users` (`id_number`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES (1,'64022222',64),(2,'64020934',64);
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
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
INSERT INTO `users` VALUES ('กันตพงศ์','วิชาแหลม','11112222','$2b$12$MyVxszICHKmAzhUZlFqYj.0Szck3vJwaGU/jROepqWE5f7pWQwn5a','teacher'),('Makk','Noy','11223344','$2b$12$GVOYczNipAxe8xKjQrpCGuBdJ884M4dgZGxK.YCTMq8XLzkewkKgK','teacher'),('Kanta','Wicha','64020934','$2b$12$0fHGTX/vl4npqDIBzfYRNOny72YFoTMx8eqTiDKWl8M2cXuRLiYDO','student'),('Mak','Mee','64022222','$2b$12$pmZufll6vHa2cKvsQkzjQOAGIXOkOnXOfIame.CQB4zXfjzpaM/HK','student');
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

-- Dump completed on 2024-09-15  2:25:51
