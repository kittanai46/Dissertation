CREATE TABLE IF NOT EXISTS `course_conditions` (
  `course_code` varchar(20) NOT NULL,
  `section` int NOT NULL,
  `late_limit` int NOT NULL DEFAULT 0,
  `max_score` decimal(6,2) DEFAULT NULL,
  PRIMARY KEY (`course_code`, `section`),
  CONSTRAINT `course_conditions_course_fk`
    FOREIGN KEY (`course_code`, `section`)
    REFERENCES `courses` (`course_code`, `section`)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT `course_conditions_late_limit_check` CHECK (`late_limit` >= 0),
  CONSTRAINT `course_conditions_max_score_check` CHECK (`max_score` IS NULL OR `max_score` >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
