DROP TABLE IF EXISTS `st_model_safety_statistics`;
CREATE TABLE `st_model_safety_statistics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `st_model_safety_statistics_model_id` int(11) NOT NULL,  
  `st_model_safety_statistics_year` decimal(4,0) NOT NULL,
  `st_model_safety_statistics_child` decimal(3,0) NOT NULL,
  `st_model_safety_statistics_adult` decimal(3,0) NOT NULL,
  `st_model_safety_statistics_pedestrian` decimal(3,0) NOT NULL,
  `st_model_safety_statistics_assist` decimal(3,0) NOT NULL,
  `st_model_safety_statistics_stars` decimal(1,0) NOT NULL,
  `st_model_safety_statistics_active` tinyint(1) NOT NULL,
  `st_model_safety_statistics_changed` tinyint(1) DEFAULT NULL,
  `st_model_safety_statistics_deleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `st_model_safety_statistics_model_id_fk` (`st_model_safety_statistics_model_id`),
  CONSTRAINT `st_model_safety_statistics_model_id_fk` FOREIGN KEY (`st_model_safety_statistics_model_id`) REFERENCES `st_models` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
