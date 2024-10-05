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
  `status` enum('present','absent','late','leave') NOT NULL,
  `check_in_time` time DEFAULT NULL,
  `is_edited` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_attendance` (`course_code`,`section`,`student_id`,`date`)
) ENGINE=InnoDB AUTO_INCREMENT=213 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
INSERT INTO `attendance` VALUES (153,'226482',1,'64020934','2024-09-15','present','15:14:14',0),(154,'226482',1,'64022222','2024-09-15','late','15:16:15',0),(155,'226482',1,'64123456','2024-09-15','absent','15:20:33',0),(181,'226482',1,'64020934','2024-09-16','present','16:20:52',0),(182,'226482',1,'64022222','2024-09-16','late','16:21:19',0),(183,'226482',1,'64123456','2024-09-16','absent','16:25:45',0),(198,'226482',1,'64020934','2024-09-17','present','02:34:29',0),(202,'226482',1,'64123456','2024-09-17','late','02:36:29',0),(203,'226482',1,'64022222','2024-09-17','leave','02:38:06',1),(210,'226482',1,'64022222','2024-09-14','late','13:03:22',0),(211,'226482',1,'64020934','2024-09-14','absent',NULL,0),(212,'226482',1,'64123456','2024-09-14','absent','13:14:15',0);
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
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_rules`
--

LOCK TABLES `attendance_rules` WRITE;
/*!40000 ALTER TABLE `attendance_rules` DISABLE KEYS */;
INSERT INTO `attendance_rules` VALUES (15,'226482',1,'2024-09-16','16:21:00','16:22:00'),(16,'226482',1,'2024-09-15','15:15:00','15:20:00'),(17,'226482',1,'2024-09-17','02:35:00','02:37:00'),(18,'226482',1,'2024-09-14','13:00:00','13:05:00');
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `enrollments`
--

LOCK TABLES `enrollments` WRITE;
/*!40000 ALTER TABLE `enrollments` DISABLE KEYS */;
INSERT INTO `enrollments` VALUES (1,'64020934','226482',1),(2,'64022222','226482',1),(3,'64020934','1234',2),(4,'64123456','226482',1),(5,'64020934','1112',1),(6,'64022222','1112',1);
/*!40000 ALTER TABLE `enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_approval_history`
--

DROP TABLE IF EXISTS `leave_approval_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_approval_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `leave_request_id` int NOT NULL,
  `approver_id` varchar(30) NOT NULL,
  `action` varchar(50) DEFAULT NULL,
  `comment` text,
  `action_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `approver_id` (`approver_id`),
  KEY `idx_leave_request_id_history` (`leave_request_id`),
  CONSTRAINT `leave_approval_history_ibfk_1` FOREIGN KEY (`leave_request_id`) REFERENCES `leave_requests` (`id`),
  CONSTRAINT `leave_approval_history_ibfk_2` FOREIGN KEY (`approver_id`) REFERENCES `users` (`id_number`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_approval_history`
--

LOCK TABLES `leave_approval_history` WRITE;
/*!40000 ALTER TABLE `leave_approval_history` DISABLE KEYS */;
INSERT INTO `leave_approval_history` VALUES (1,7,'11223344','อนุมัติ','','2024-09-28 16:26:31'),(2,8,'11223344','อนุมัติ','','2024-09-29 17:42:59'),(3,5,'11223344','อนุมัติ','','2024-09-29 17:43:08'),(4,4,'11223344','อนุมัติ','ggez','2024-09-29 17:43:15'),(5,3,'11223344','อนุมัติ','hhhh','2024-09-29 17:43:22'),(6,2,'11223344','อนุมัติ','test','2024-09-29 17:43:29'),(7,1,'11223344','อนุมัติ','hahaaaa','2024-09-29 17:43:36'),(8,9,'11223344','อนุมัติ','','2024-09-29 18:07:40'),(9,10,'11223344','ปฏิเสธ','','2024-09-29 18:12:54'),(10,10,'11223344','ไม่อนุมัติ','','2024-09-29 18:15:01'),(11,11,'11223344','ไม่อนุมัติ','bbb','2024-09-29 18:16:33');
/*!40000 ALTER TABLE `leave_approval_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_attachments`
--

DROP TABLE IF EXISTS `leave_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_attachments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `leave_request_id` int NOT NULL,
  `file_type` enum('ใบลา','ใบรับรองแพทย์') NOT NULL,
  `file_url` varchar(255) NOT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_leave_request_id` (`leave_request_id`),
  CONSTRAINT `leave_attachments_ibfk_1` FOREIGN KEY (`leave_request_id`) REFERENCES `leave_requests` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_attachments`
--

LOCK TABLES `leave_attachments` WRITE;
/*!40000 ALTER TABLE `leave_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `leave_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_requests`
--

DROP TABLE IF EXISTS `leave_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_id` varchar(30) NOT NULL,
  `course_id` int NOT NULL,
  `teacher_id` varchar(30) DEFAULT NULL,
  `leave_type_id` int NOT NULL,
  `reason` text NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `leave_document_url` varchar(255) DEFAULT NULL,
  `medical_certificate_url` varchar(255) DEFAULT NULL,
  `status` enum('รออนุมัติ','อนุมัติ','ไม่อนุมัติ') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approver_id` varchar(30) DEFAULT NULL,
  `approval_date` timestamp NULL DEFAULT NULL,
  `approval_comment` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `approver_id` (`approver_id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_teacher_id` (`teacher_id`),
  KEY `idx_course_id` (`course_id`),
  KEY `idx_leave_type_id` (`leave_type_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `leave_requests_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `users` (`id_number`),
  CONSTRAINT `leave_requests_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`),
  CONSTRAINT `leave_requests_ibfk_3` FOREIGN KEY (`teacher_id`) REFERENCES `users` (`id_number`),
  CONSTRAINT `leave_requests_ibfk_4` FOREIGN KEY (`leave_type_id`) REFERENCES `leave_types` (`id`),
  CONSTRAINT `leave_requests_ibfk_5` FOREIGN KEY (`approver_id`) REFERENCES `users` (`id_number`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_requests`
--

LOCK TABLES `leave_requests` WRITE;
/*!40000 ALTER TABLE `leave_requests` DISABLE KEYS */;
INSERT INTO `leave_requests` VALUES (1,'64020934',4,NULL,2,'fhjhcfgg','2024-09-27','2024-09-28',NULL,NULL,'อนุมัติ','11223344','2024-09-29 17:43:36',NULL,'2024-09-27 16:35:12','2024-09-29 17:43:36'),(2,'64123456',4,NULL,1,'test','2024-09-28','2024-09-29',NULL,NULL,'อนุมัติ','11223344','2024-09-29 17:43:29',NULL,'2024-09-28 09:11:39','2024-09-29 17:43:29'),(3,'64020934',4,NULL,2,'pppp','2024-09-28','2024-09-29',NULL,NULL,'อนุมัติ','11223344','2024-09-29 17:43:22',NULL,'2024-09-28 09:56:09','2024-09-29 17:43:22'),(4,'64020934',4,NULL,3,'vhhgddff','2024-09-28','2024-09-30',NULL,NULL,'อนุมัติ','11223344','2024-09-29 17:43:15',NULL,'2024-09-28 10:33:15','2024-09-29 17:43:15'),(5,'64020934',11,NULL,3,'fggggg','2024-09-28','2024-09-30',NULL,NULL,'อนุมัติ','11223344','2024-09-29 17:43:08',NULL,'2024-09-28 10:43:22','2024-09-29 17:43:08'),(6,'64020934',8,NULL,1,'ggfdgg','2024-09-28','2024-09-30',NULL,NULL,'รออนุมัติ',NULL,NULL,NULL,'2024-09-28 15:59:55','2024-09-28 15:59:55'),(7,'64020934',4,NULL,2,'https://drive.google.com/file/d/1iXq7ZzDi50ROZ2JzUKcHgxle_iISChw4/view?usp=sharingu','2024-09-28','2024-09-29',NULL,NULL,'อนุมัติ','11223344','2024-09-28 16:26:31','','2024-09-28 16:00:44','2024-09-28 16:26:31'),(8,'64020934',4,NULL,1,'gggggg','2024-09-28','2024-09-29',NULL,NULL,'อนุมัติ','11223344','2024-09-29 17:42:59',NULL,'2024-09-28 16:31:24','2024-09-29 17:42:59'),(9,'64020934',4,NULL,2,'gggg','2024-09-30','2024-09-30',NULL,NULL,'อนุมัติ','11223344','2024-09-29 18:07:40',NULL,'2024-09-29 17:53:06','2024-09-29 18:07:40'),(10,'64123456',4,NULL,1,'ggggg','2024-09-30','2024-10-11',NULL,NULL,'ไม่อนุมัติ','11223344','2024-09-29 18:15:01',NULL,'2024-09-29 18:12:32','2024-09-29 18:15:01'),(11,'64123456',4,NULL,2,'ffggg','2024-09-30','2024-09-30',NULL,NULL,'ไม่อนุมัติ','11223344','2024-09-29 18:16:33',NULL,'2024-09-29 18:16:04','2024-09-29 18:16:33');
/*!40000 ALTER TABLE `leave_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leave_types`
--

DROP TABLE IF EXISTS `leave_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leave_types` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type_name` varchar(50) NOT NULL,
  `description` text,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `type_name` (`type_name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leave_types`
--

LOCK TABLES `leave_types` WRITE;
/*!40000 ALTER TABLE `leave_types` DISABLE KEYS */;
INSERT INTO `leave_types` VALUES (1,'ลากิจ','การลาเพื่อทำธุระส่วนตัว',1,'2024-09-26 14:14:07','2024-09-26 14:14:07'),(2,'ลาป่วย','การลาเนื่องจากการเจ็บป่วย',1,'2024-09-26 14:14:07','2024-09-26 14:14:07'),(3,'ลาอุบัติเหตุ','การลาเนื่องจากประสบอุบัติเหตุ',1,'2024-09-26 14:14:07','2024-09-26 14:14:07');
/*!40000 ALTER TABLE `leave_types` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `log_attendance`
--

LOCK TABLES `log_attendance` WRITE;
/*!40000 ALTER TABLE `log_attendance` DISABLE KEYS */;
INSERT INTO `log_attendance` VALUES (25,'64020934',226,4821,'2024-09-16','01:58:34'),(26,'64022222',226,4821,'2024-09-16','02:41:48'),(27,'64022222',226,4821,'2024-09-16','03:50:30'),(28,'64020934',226,4821,'2024-09-16','03:50:30'),(29,'64020934',226,4821,'2024-09-16','14:52:35'),(30,'64022222',226,4821,'2024-09-16','14:53:23'),(31,'64123456',226,4821,'2024-09-16','14:58:55'),(32,'64022222',226,4821,'2024-09-16','15:01:05'),(33,'64123456',226,4821,'2024-09-16','15:07:32'),(34,'64022222',226,4821,'2024-09-16','15:10:25'),(35,'64020934',226,4821,'2024-09-16','15:47:22'),(36,'64020934',226,4821,'2024-09-16','15:47:22'),(37,'64020934',226,4821,'2024-09-16','15:47:22'),(38,'64022222',226,4821,'2024-09-16','15:47:30'),(39,'64020934',226,4821,'2024-09-16','15:48:04'),(40,'64123456',226,4821,'2024-09-16','15:49:31'),(41,'64022222',226,4821,'2024-09-16','15:52:37'),(42,'64020934',226,4821,'2024-09-16','15:55:07'),(43,'64020934',226,4821,'2024-09-16','15:55:34'),(44,'64020934',226,4821,'2024-09-16','16:02:15'),(45,'64022222',226,4821,'2024-09-16','16:02:57'),(46,'64022222',226,4821,'2024-09-16','16:03:45'),(47,'64020934',226,4821,'2024-09-16','16:04:01'),(48,'64020934',226,4821,'2024-09-16','16:20:52'),(49,'64022222',226,4821,'2024-09-16','16:21:19'),(50,'64123456',226,4821,'2024-09-16','16:25:45'),(51,'64020934',226,4821,'2024-09-17','02:34:29'),(52,'64123456',226,4821,'2024-09-17','02:36:29'),(53,'64022222',226,4821,'2024-09-17','02:38:06');
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
  `title` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (13,11223344,'226482',1,'เนื่องจากสถานการณ์น้ำท่วม จึงขอแจ้งนิสิตในรายวิชาว่า วันนี้งดการเรียนการสอน','2024-09-17 16:24:04','วันที่ 18/9/2567 งดการเรียนการสอน'),(14,11223344,'1112',1,'เนื่องจากสถานการณ์น้ำท่วม จึงขอแจ้งนิสิตในรายวิชา ขอนัดการเรียนการสอนเพื่อชดเชยในจากวันที่เกิดน้ำท่วม','2024-09-17 16:38:34','วันเสาร์ ที่ 21/9/2567 แจ้งนัดการเรียนการสอนชดเชย');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `pending_leave_requests`
--

DROP TABLE IF EXISTS `pending_leave_requests`;
/*!50001 DROP VIEW IF EXISTS `pending_leave_requests`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `pending_leave_requests` AS SELECT 
 1 AS `leave_request_id`,
 1 AS `student_id`,
 1 AS `student_first_name`,
 1 AS `student_last_name`,
 1 AS `course_code`,
 1 AS `course_name`,
 1 AS `leave_type`,
 1 AS `reason`,
 1 AS `start_date`,
 1 AS `end_date`,
 1 AS `status`,
 1 AS `created_at`*/;
SET character_set_client = @saved_cs_client;

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
INSERT INTO `users` VALUES ('กนกพล','หงษ์พัตรา','11112222','$2b$12$MyVxszICHKmAzhUZlFqYj.0Szck3vJwaGU/jROepqWE5f7pWQwn5a','teacher'),('ณชา','ม่วงทอง','11223344','$2b$12$GVOYczNipAxe8xKjQrpCGuBdJ884M4dgZGxK.YCTMq8XLzkewkKgK','teacher'),('อภิภู','ส่งศรี','12121212','$2b$12$HCb2NsTBJSPBDHi9p/VTEut2yDmt1.9DSYXTcDRGwYlP8pW2QC3S6','teacher'),('ภาสกร','สุขสวัสดิ์','64020934','$2b$12$0fHGTX/vl4npqDIBzfYRNOny72YFoTMx8eqTiDKWl8M2cXuRLiYDO','student'),('ภูริทัต','ป้องภัย','64022222','$2b$12$pmZufll6vHa2cKvsQkzjQOAGIXOkOnXOfIame.CQB4zXfjzpaM/HK','student'),('ธนินท์','รักษาทรัพย์','64123456','$2b$12$r9hrDRCXorAmELZH.TnOduyTUEvGojSCCDPHOFdBvco./9qH.AKgO','student');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `pending_leave_requests`
--

/*!50001 DROP VIEW IF EXISTS `pending_leave_requests`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `pending_leave_requests` AS select `lr`.`id` AS `leave_request_id`,`lr`.`student_id` AS `student_id`,`u`.`first_name` AS `student_first_name`,`u`.`last_name` AS `student_last_name`,`c`.`course_code` AS `course_code`,`c`.`course_name` AS `course_name`,`lt`.`type_name` AS `leave_type`,`lr`.`reason` AS `reason`,`lr`.`start_date` AS `start_date`,`lr`.`end_date` AS `end_date`,`lr`.`status` AS `status`,`lr`.`created_at` AS `created_at` from (((`leave_requests` `lr` join `users` `u` on((`lr`.`student_id` = `u`.`id_number`))) join `courses` `c` on((`lr`.`course_id` = `c`.`course_id`))) join `leave_types` `lt` on((`lr`.`leave_type_id` = `lt`.`id`))) where (`lr`.`status` = 'รอการอนุมัติ') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-09-30  1:20:05
