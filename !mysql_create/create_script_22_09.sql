CREATE DATABASE  IF NOT EXISTS `statistic1`/*!40100 DEFAULT CHARACTER SET utf8 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `statistic1`;

DROP TABLE IF EXISTS `st_brands`;
CREATE TABLE `st_brands` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `st_brands_name` varchar(150) CHARACTER SET utf8 NOT NULL,
  `st_brands_prp_property_value` varchar(100) DEFAULT NULL,
  `st_brands_active` tinyint(1) NOT NULL,
  `st_brands_changed` tinyint(1) DEFAULT NULL,
  `st_brands_deleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2071 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `st_colours`;
CREATE TABLE `st_colours` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `st_colours_name` varchar(10) NOT NULL,
  `st_colours_active` tinyint(1) NOT NULL,
  `st_colours_changed` tinyint(1) DEFAULT NULL,
  `st_colours_deleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=170 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `st_fuel`;
CREATE TABLE `st_fuel` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `st_fuel_name` varchar(150) NOT NULL,
  `st_fuel_active` tinyint(1) NOT NULL,
  `st_fuel_changed` tinyint(1) DEFAULT NULL,
  `st_fuel_deleted` tinyint(1) DEFAULT NULL,
  `st_fuel_prp_property_value` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=238 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `st_groups`;
CREATE TABLE `st_groups` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `st_groups_name` varchar(150) NOT NULL,
  `st_groups_active` tinyint(1) NOT NULL,
  `st_groups_changed` tinyint(1) DEFAULT NULL,
  `st_groups_deleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=258 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `st_models`;
CREATE TABLE `st_models` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `st_models_name` varchar(150) NOT NULL,
  `st_models_brands_id` int(11) NOT NULL,
  `st_models_groups_id` int(11) NOT NULL,
  `st_models_active` tinyint(1) NOT NULL,
  `st_models_changed` tinyint(1) DEFAULT NULL,
  `st_models_deleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `st_brands_st_models_fk` (`st_models_brands_id`),
  KEY `st_models_st_groups_fk` (`st_models_groups_id`),
  CONSTRAINT `st_brands_st_models_fk` FOREIGN KEY (`st_models_brands_id`) REFERENCES `st_brands` (`id`),
  CONSTRAINT `st_models_st_groups_fk` FOREIGN KEY (`st_models_groups_id`) REFERENCES `st_groups` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15978 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `st_model_statistics`;
CREATE TABLE `st_model_statistics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `st_model_statistics_date_year` decimal(4,0) NOT NULL,
  `st_model_statistics_date_month` decimal(2,0) NOT NULL,
  `st_model_statistics_count` int(11) NOT NULL,
  `st_model_statistics_models_id` int(11) NOT NULL,
  `st_model_statistics_fuel_id` int(11) NOT NULL,
  `st_model_active` tinyint(1) NOT NULL,
  `st_model_changed` tinyint(1) DEFAULT NULL,
  `st_model_deleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `st_model_statistics_st_fuel_fk` (`st_model_statistics_fuel_id`),
  KEY `st_models_st_model_statistics_fk` (`st_model_statistics_models_id`),
  CONSTRAINT `st_model_statistics_st_fuel_fk` FOREIGN KEY (`st_model_statistics_fuel_id`) REFERENCES `st_fuel` (`id`),
  CONSTRAINT `st_models_st_model_statistics_fk` FOREIGN KEY (`st_model_statistics_models_id`) REFERENCES `st_models` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=105320 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `st_old_statistics`;
CREATE TABLE `st_old_statistics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `st_old_statistics_date_year` decimal(4,0) NOT NULL,
  `st_old_statistics_date_month` decimal(2,0) NOT NULL,
  `st_old_statistics_count` int(11) NOT NULL,
  `st_old_statistics_age` decimal(2,0) NOT NULL,
  `st_old_statistics_brands_id` int(11) NOT NULL,
  `st_old_active` tinyint(1) NOT NULL,
  `st_old_changed` tinyint(1) DEFAULT NULL,
  `st_old_deleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `st_brands_st_old_statistics` (`st_old_statistics_brands_id`),
  CONSTRAINT `st_brands_st_old_statistics` FOREIGN KEY (`st_old_statistics_brands_id`) REFERENCES `st_brands` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18840 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `st_brand_colour_statistics`;
CREATE TABLE `st_brand_colour_statistics` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `st_brand_colour_statistics_count` int(11) NOT NULL,
  `st_brand_colour_statistics_brands_id` int(11) NOT NULL,
  `st_brand_colour_statistics_colours_id` int(11) NOT NULL,
  `st_brand_colour_statistics_active` tinyint(1) NOT NULL,
  `st_brand_colour_statistics_changed` tinyint(1) DEFAULT NULL,
  `st_brand_colour_statistics_deleted` tinyint(1) DEFAULT NULL,
  `st_brand_colour_statistics_date_year` decimal(4,0) NOT NULL,
  `st_brand_colour_statistics_date_month` decimal(4,0) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `st_brand_colour_statistics_st_brands_fk` (`st_brand_colour_statistics_brands_id`),
  KEY `st_brand_colour_statistics_st_colours_fk` (`st_brand_colour_statistics_colours_id`),
  CONSTRAINT `st_brand_colour_statistics_st_brands_fk` FOREIGN KEY (`st_brand_colour_statistics_brands_id`) REFERENCES `st_brands` (`id`),
  CONSTRAINT `st_brand_colour_statistics_st_colours_fk` FOREIGN KEY (`st_brand_colour_statistics_colours_id`) REFERENCES `st_colours` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47795 DEFAULT CHARSET=utf8;

CREATE TABLE `st_prp_property` (
  `idst_prp_property` int(11) NOT NULL,
  `st_prp_property_code` varchar(150) NOT NULL,
  `st_prp_property_model` int(11) NOT NULL,
  PRIMARY KEY (`idst_prp_property`),
  KEY `st_prp_property_model` (`st_prp_property_model`),
  CONSTRAINT `st_prp_property_model` FOREIGN KEY (`st_prp_property_model`) REFERENCES `st_models` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET GLOBAL log_bin_trust_function_creators = 1;

DROP FUNCTION IF EXISTS insertBrandsJson;
DELIMITER //
CREATE FUNCTION insertBrandsJson(p_json JSON)
RETURNS JSON
BEGIN
    DECLARE i INT UNSIGNED
        DEFAULT 0;
    DECLARE v_count INT UNSIGNED
        DEFAULT JSON_LENGTH(p_json);
    DECLARE v_current_item VARCHAR(150)
        DEFAULT NULL;
	DECLARE not_inserted JSON
		DEFAULT JSON_ARRAY();
	WHILE i < v_count DO
        SET v_current_item :=
            JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
			IF NOT EXISTS(SELECT 1 FROM st_brands WHERE st_brands_name = v_current_item) THEN
				INSERT INTO st_brands(st_brands_name, st_brands_active,st_brands_changed,st_brands_deleted)
				VALUES(v_current_item,true,false,false);
				SET not_inserted := JSON_ARRAY_APPEND(not_inserted, '$', v_current_item);
			END IF;
        SET i := i + 1;
    END WHILE;
    RETURN not_inserted;
END//

DROP FUNCTION IF EXISTS insertGroupsJson;
DELIMITER //
CREATE FUNCTION insertGroupsJson(p_json JSON)
RETURNS JSON
BEGIN
    DECLARE i INT UNSIGNED
        DEFAULT 0;
    DECLARE v_count INT UNSIGNED
        DEFAULT JSON_LENGTH(p_json);
    DECLARE v_current_item VARCHAR(150)
        DEFAULT NULL;
	DECLARE not_inserted JSON
		DEFAULT JSON_ARRAY();
	WHILE i < v_count DO
        SET v_current_item :=
            JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
		IF NOT EXISTS(SELECT 1 FROM st_groups WHERE st_groups_name = v_current_item) THEN
			INSERT INTO st_groups(st_groups_name, st_groups_active,st_groups_changed,st_groups_deleted)
			VALUES(v_current_item,true,false,false);
            SET not_inserted := JSON_ARRAY_APPEND(not_inserted, '$', v_current_item);
		END IF;
        SET i := i + 1;
    END WHILE;
    RETURN not_inserted;
END//

DROP FUNCTION IF EXISTS insertColoursJson;
DELIMITER //
CREATE FUNCTION insertColoursJson(p_json JSON)
RETURNS JSON
BEGIN
    DECLARE i INT UNSIGNED
        DEFAULT 0;
    DECLARE v_count INT UNSIGNED
        DEFAULT JSON_LENGTH(p_json);
    DECLARE v_current_item VARCHAR(150)
        DEFAULT NULL;
	DECLARE not_inserted JSON
		DEFAULT JSON_ARRAY();
	WHILE i < v_count DO
        SET v_current_item :=
            JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
		IF NOT EXISTS(SELECT 1 FROM st_colours WHERE st_colours_name = v_current_item) THEN
			INSERT INTO st_colours(st_colours_name,st_colours_active,st_colours_changed,st_colours_deleted) VALUES(v_current_item, TRUE, FALSE, FALSE);
			SET not_inserted := JSON_ARRAY_APPEND(not_inserted, '$', v_current_item);
        END IF;
        SET i := i + 1;
    END WHILE;
    RETURN not_inserted;
END//

DROP PROCEDURE IF EXISTS insertColoursStatisticJson;
DELIMITER //
CREATE PROCEDURE insertColoursStatisticJson(p_json JSON)
BEGIN
    DECLARE i INT UNSIGNED
        DEFAULT 0;
    DECLARE v_count INT UNSIGNED
        DEFAULT JSON_LENGTH(p_json);
    DECLARE v_current_brand VARCHAR(150)
        DEFAULT NULL;
	DECLARE v_current_colour VARCHAR(150)
        DEFAULT NULL;
	DECLARE v_current_count INTEGER
        DEFAULT NULL;
	DECLARE not_inserted JSON
		DEFAULT JSON_OBJECT();
	DECLARE v_brand_id BIGINT;
    DECLARE v_colour_id BIGINT;
    DECLARE v_year DECIMAL(4,0);
    DECLARE v_month DECIMAL(2,0);
    SET v_year := JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
	SET i := i + 1;
    SET v_month := JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
	SET i := i + 1;
	WHILE i < v_count DO
        SET v_current_brand :=
            JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
        SET i := i + 1;
		SET v_current_colour :=
            JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
        SET i := i + 1;
		SET v_current_count :=
            CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']'))) AS UNSIGNED INTEGER);
		SELECT id INTO v_brand_id FROM st_brands WHERE st_brands_name = v_current_brand;
		SELECT id INTO v_colour_id FROM st_colours WHERE st_colours_name = v_current_colour;
		INSERT INTO st_brand_colour_statistics(st_brand_colour_statistics_count,st_brand_colour_statistics_brands_id,st_brand_colour_statistics_colours_id,st_brand_colour_statistics_active,st_brand_colour_statistics_changed,st_brand_colour_statistics_deleted, st_brand_colour_statistics_date_year, st_brand_colour_statistics_date_month)
			VALUES(v_current_count,v_brand_id,v_colour_id,TRUE,FALSE,FALSE, v_year, v_month);
        SET i := i + 1;
    END WHILE;
END//

DROP FUNCTION IF EXISTS insertFuelTypesJson;
DELIMITER //
CREATE FUNCTION insertFuelTypesJson(p_json JSON)
RETURNS JSON
BEGIN
    DECLARE i INT UNSIGNED
        DEFAULT 0;
    DECLARE v_count INT UNSIGNED
        DEFAULT JSON_LENGTH(p_json);
    DECLARE v_current_item VARCHAR(150)
        DEFAULT NULL;
	DECLARE not_inserted JSON
		DEFAULT JSON_ARRAY();
	WHILE i < v_count DO
        SET v_current_item :=
            JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
		IF NOT EXISTS(SELECT 1 FROM st_fuel WHERE st_fuel_name = v_current_item) THEN
			INSERT INTO st_fuel(st_fuel_name, st_fuel_active,st_fuel_changed,st_fuel_deleted)
				VALUES(v_current_item,true,false,false);
			SET not_inserted := JSON_ARRAY_APPEND(not_inserted, '$', v_current_item);
		END IF;
        SET i := i + 1;
    END WHILE;
    RETURN not_inserted;
END//

DROP PROCEDURE IF EXISTS insertOldStatisticJson;
DELIMITER //
CREATE PROCEDURE insertOldStatisticJson(p_json JSON)
BEGIN
    DECLARE i INT UNSIGNED
        DEFAULT 0;
    DECLARE v_count INT UNSIGNED
        DEFAULT JSON_LENGTH(p_json);
    DECLARE v_current_brand VARCHAR(150)
        DEFAULT NULL;
	DECLARE v_current_age INTEGER
        DEFAULT NULL;
	DECLARE v_current_count INTEGER
        DEFAULT NULL;
	DECLARE v_brand_id BIGINT;
    DECLARE v_age DECIMAL(2,0);
    DECLARE v_year DECIMAL(4,0);
    DECLARE v_month DECIMAL(2,0);
    SET v_year := JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
	SET i := i + 1;
    SET v_month := JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
	SET i := i + 1;
	WHILE i < v_count DO
        SET v_current_brand :=
            JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
        SET i := i + 1;
		SET v_age :=
            CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']'))) AS UNSIGNED INTEGER);
        SET i := i + 1;
		SET v_current_count :=
            CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']'))) AS UNSIGNED INTEGER);
		SELECT id INTO v_brand_id FROM st_brands WHERE st_brands_name = v_current_brand;
		INSERT INTO st_old_statistics(st_old_statistics_count,st_old_statistics_brands_id,st_old_statistics_age,st_old_active,st_old_changed,st_old_deleted, st_old_statistics_date_year, st_old_statistics_date_month)
		VALUES(v_current_count,v_brand_id,v_age,TRUE,FALSE,FALSE, v_year, v_month);
        SET i := i + 1;
    END WHILE;
END//

DROP FUNCTION IF EXISTS insertModelGroupJson;
DELIMITER //
CREATE FUNCTION insertModelGroupJson(p_json JSON)
RETURNS JSON
BEGIN
    DECLARE i INT UNSIGNED
        DEFAULT 0;
    DECLARE v_count INT UNSIGNED
        DEFAULT JSON_LENGTH(p_json);
    DECLARE v_current_brand VARCHAR(150)
        DEFAULT NULL;
	DECLARE v_current_model VARCHAR(150)
        DEFAULT NULL;
	DECLARE v_group VARCHAR(150)
        DEFAULT NULL;
	DECLARE not_inserted JSON
		DEFAULT JSON_OBJECT();
	DECLARE v_brand_id BIGINT;
    DECLARE v_group_id BIGINT;
	SET v_group := JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
	SET i := i + 1;
	SELECT id INTO v_group_id FROM st_groups WHERE st_groups_name = v_group;
	WHILE i < v_count DO
        SET v_current_model :=
            JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
        SET i := i + 1;
		SET v_current_brand :=
            JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
        SET i := i + 1;
        IF NOT EXISTS(SELECT 1 FROM st_brands WHERE st_brands_name = v_current_brand) THEN
			INSERT INTO st_brands(st_brands_name,st_brands_active,st_brands_changed,st_brands_deleted)
            VALUES(v_current_brand, true, false, false);
		END IF;
		SELECT id INTO v_brand_id FROM st_brands WHERE st_brands_name = v_current_brand;
        IF NOT EXISTS(SELECT 1 FROM st_models WHERE st_models_name = v_current_model AND st_models_brands_id = v_brand_id AND st_models_groups_id = v_group_id) THEN
			INSERT INTO st_models(st_models_name, st_models_brands_id, st_models_groups_id,st_models_active,st_models_changed,st_models_deleted) 
			VALUES(v_current_model,v_brand_id,v_group_id,true,false,false);
			SET not_inserted := JSON_ARRAY_APPEND(not_inserted, '$', v_current_model);
		END IF;
    END WHILE;
    RETURN not_inserted;    
END//

DROP PROCEDURE IF EXISTS insertModelGroupStatisticsJson;
DELIMITER //
CREATE PROCEDURE insertModelGroupStatisticsJson(p_json JSON)
BEGIN
    DECLARE i INT UNSIGNED
        DEFAULT 0;
    DECLARE v_count INT UNSIGNED
        DEFAULT JSON_LENGTH(p_json);
	DECLARE v_current_model VARCHAR(150)
        DEFAULT NULL;
	DECLARE v_current_count INTEGER
        DEFAULT NULL;
	DECLARE v_current_fuel VARCHAR(150)
        DEFAULT NULL;
	DECLARE v_group_id BIGINT;
	DECLARE v_model_id BIGINT;
	DECLARE v_fuel_id BIGINT;
    DECLARE v_year DECIMAL(4,0);
    DECLARE v_month DECIMAL(2,0);
    DECLARE v_group VARCHAR(150);
    SET v_year := JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
	SET i := i + 1;
    SET v_month := JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
	SET i := i + 1;
	SET v_group := JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
	SET i := i + 1;
    SELECT id INTO v_group_id FROM st_groups WHERE st_groups_name = v_group;
	WHILE i < v_count DO
        SET v_current_model :=
            JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
        SET i := i + 1;
		SET v_current_fuel :=
            JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']')));
        SET i := i + 1;
		SET v_current_count :=
            CAST(JSON_UNQUOTE(JSON_EXTRACT(p_json, CONCAT('$[', i, ']'))) AS UNSIGNED INTEGER);
		SET i := i + 1;
		SELECT id INTO v_fuel_id FROM st_fuel WHERE st_fuel_name = v_current_fuel;
		SELECT id INTO v_model_id FROM st_models WHERE st_models_groups_id = v_group_id AND st_models_name = v_current_model;
		INSERT INTO st_model_statistics(st_model_statistics_count,st_model_statistics_models_id,st_model_statistics_fuel_id,st_model_active,st_model_changed,st_model_deleted, st_model_statistics_date_year, st_model_statistics_date_month)
		VALUES(v_current_count,v_model_id,v_fuel_id,TRUE,FALSE,FALSE, v_year, v_month);
    END WHILE;
END//
