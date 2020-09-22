DROP PROCEDURE IF EXISTS selectNewBrands;
DELIMITER //
CREATE PROCEDURE selectNewBrands(p_json JSON)
BEGIN
	DECLARE v_type VARCHAR(60);
    DECLARE v_lim INT;
    DECLARE v_time_type VARCHAR(10);
    DECLARE v_brand VARCHAR(150);
    DECLARE v_model VARCHAR(150);
    DECLARE v_group VARCHAR(150);
	DECLARE v_fuel VARCHAR(150);
    DECLARE v_sum INT;
    DECLARE v_year_from DECIMAL(4,0);
    DECLARE v_month_from DECIMAL(2,0);
    DECLARE v_year_to DECIMAL(4,0);
    DECLARE v_month_to DECIMAL(2,0);
	SET v_year_from :=
		JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.year_from'));
	SET v_month_from :=
		JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.month_from'));
	SET v_year_to :=
		JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.year_to'));
	SET v_month_to :=
		JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.month_to'));
    SET v_type :=
		JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.type'));
        -- vsechny znacky 
	IF v_type = 'new_brands' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
		SELECT st_brands.st_brands_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
			st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_brands ON st_brands.id = st_models_brands_id
			WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_brands_name
			ORDER BY s DESC LIMIT v_lim;
    END IF;
    -- vsechny modely od jedne znacky
	IF v_type = 'new_models_of_brand' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
		SELECT st_models.st_models_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
			st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_brands ON st_brands.id = st_models_brands_id
			WHERE st_brands_name = v_brand AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_models_name
			ORDER BY s DESC LIMIT v_lim;
    END IF;
    -- vsechny modely
	IF v_type = 'new_models' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
		SELECT st_models.st_models_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
			st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
			WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_models_name
			ORDER BY s DESC LIMIT v_lim;
    END IF;
    -- vsechny top skupiny
	IF v_type = 'new_groups' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
		SELECT st_groups_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
			st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_groups ON st_models_groups_id = st_groups.id
			WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_groups_name
			ORDER BY s DESC LIMIT v_lim;
    END IF;
    -- vsechny top paliva
    IF v_type = 'new_fuels' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
		SELECT st_fuel_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
			st_model_statistics JOIN st_fuel ON st_fuel.id = st_model_statistics_fuel_id
			WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to) 
			GROUP BY st_fuel_name
			ORDER BY s DESC LIMIT v_lim;
    END IF;
    -- vsechny stare znacky? 
	IF v_type = 'old_brands' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
		SELECT st_brands.st_brands_name as 'lbl', SUM(st_old_statistics.st_old_statistics_count) as 's' FROM st_old_statistics
			JOIN st_brands ON st_old_statistics_brands_id = st_brands.id
			WHERE MAKEDATE(st_old_statistics_date_year,st_old_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_brands_name
			ORDER BY s DESC LIMIT v_lim;
    END IF;
    -- celkove vsechny typy paliva pro dany model
	IF v_type = 'new_models_of_model_fuels' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_model = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.model'));
		SELECT st_fuel.st_fuel_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
			st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_fuel ON st_model_statistics_fuel_id = st_fuel.id
			WHERE st_models_name = v_model
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_model_statistics_fuel_id
			HAVING s > 0
			ORDER BY s DESC LIMIT v_lim;
    END IF;
    -- vsechny kategorie pro dany model
	IF v_type = 'new_model_categories' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_model = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.model'));
		SELECT st_groups.st_groups_name as 'lbl' FROM st_model_statistics
			JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_groups ON st_models_groups_id = st_groups.id
			WHERE st_models_name = v_model 
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_models_groups_id
			ORDER BY st_groups_name LIMIT v_lim;
    END IF;
    -- okoli jendoho modelu pro jeho nejpocetnejsi kategorii
	IF v_type = 'new_models_of_model_category_n_concurency' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'))/2;
        SET v_model := 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.model'));
        
        SELECT st_groups_name into v_group FROM st_model_statistics
			JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_groups ON st_models_groups_id = st_groups.id
			WHERE st_models_name = v_model 
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_groups_name
			ORDER BY SUM(st_model_statistics.st_model_statistics_count) DESC LIMIT 1;
        
		SELECT SUM(st_model_statistics.st_model_statistics_count) as 's' INTO v_sum FROM
			st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_groups ON st_models_groups_id = st_groups.id
			WHERE st_models_name = v_model and st_groups_name = v_group 
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_models_name;
        
        SELECT A.lbl, A.s FROM (
			(SELECT st_models_name as 'lbl',  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
				st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
				JOIN st_groups ON st_models_groups_id = st_groups.id
				WHERE st_groups_name = v_group
				AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
				GROUP BY st_models_name
				HAVING s <= v_sum ORDER BY s DESC LIMIT 4)
			UNION ALL (
			SELECT st_models_name as 'lbl',  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
				st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
				JOIN st_groups ON st_models_groups_id = st_groups.id
				WHERE st_groups_name = v_group
				AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
				GROUP BY st_models_name 
				HAVING s > v_sum ORDER BY s ASC LIMIT 1)) as A
		ORDER BY A.s DESC;

    END IF;
    IF v_type = 'new_model_categories_n_sum' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_model = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.model'));
		SELECT st_groups.st_groups_name as 'lbl',SUM(st_model_statistics_count) as 's' from st_model_statistics
			JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_groups ON st_models_groups_id = st_groups.id
			WHERE st_models_name = v_model 
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_models_groups_id
			ORDER BY st_groups_name LIMIT v_lim;
    END IF;
    -- predelano, vrati okoli daneho modelu celkove pro vsechny mesice, vsechny kategorie secteny (GROUP BY model_name)
	IF v_type = 'new_models_of_model_n_concurency' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'))/2;
        SET v_model := 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.model'));
		SELECT SUM(st_model_statistics.st_model_statistics_count) as 's' INTO v_sum FROM
			st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
			WHERE st_models_name = v_model
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_models_name;
        
        SELECT A.lbl, A.s FROM (
			(SELECT st_models_name as 'lbl',  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
				st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
				JOIN st_fuel ON st_model_statistics_fuel_id = st_fuel.id
				WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
				GROUP BY st_models_name
				HAVING s <= v_sum ORDER BY s DESC LIMIT 4)
			UNION ALL (
			SELECT st_models_name as 'lbl',  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
				st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
				JOIN st_fuel ON st_model_statistics_fuel_id = st_fuel.id
				WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
				GROUP BY st_models_name
				HAVING s > v_sum ORDER BY s ASC LIMIT 1)) as A
				ORDER BY A.s DESC;

    END IF;
	IF v_type = 'new_models_per_month' OR v_type = 'new_models_of_model_n_concurency_per_month' OR v_type = 'new_brands_models_of_brand_per_month' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_model = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.model'));
		SELECT SUM(st_model_statistics.st_model_statistics_count) as 's', st_model_statistics.st_model_statistics_date_year as 'year', st_model_statistics.st_model_statistics_date_month as 'month' FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics.st_model_statistics_models_id
			WHERE st_models.st_models_name = v_model
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
			ORDER BY st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;
    END IF;
	IF v_type = 'new_brands_models_of_brand_per_month_all' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
 
		SELECT v.st_models_name as 'lbl', SUM(st_model_statistics_count) as 's', st_model_statistics_date_year,st_model_statistics_date_month FROM st_model_statistics
        JOIN st_models as v ON v.id = st_model_statistics_models_id
        JOIN st_brands ON st_brands.id = v.st_models_brands_id
        INNER JOIN (SELECT st_models_name FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics_models_id
			JOIN st_brands ON st_brands.id = st_models_brands_id
			WHERE st_brands_name = v_brand 
            AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
            GROUP BY st_models_name
			ORDER BY SUM(st_model_statistics_count) DESC LIMIT 5) as A ON v.st_models_name = A.st_models_name
		WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
		GROUP BY v.st_models_name,st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
        ORDER BY v.st_models_name,st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;              
    END IF;
	IF v_type = 'new_brands_models_of_brand_per_year_all' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
 
		SELECT v.st_models_name as 'lbl', SUM(st_model_statistics_count) as 's', st_model_statistics_date_year FROM st_model_statistics
        JOIN st_models as v ON v.id = st_model_statistics_models_id
        JOIN st_brands ON st_brands.id = v.st_models_brands_id
        INNER JOIN (SELECT st_models_name FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics_models_id
			JOIN st_brands ON st_brands.id = st_models_brands_id
			WHERE st_brands_name = v_brand 
            AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
            GROUP BY st_models_name
			ORDER BY SUM(st_model_statistics_count) DESC LIMIT 5) as A ON v.st_models_name = A.st_models_name
		WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
		GROUP BY v.st_models_name, st_model_statistics.st_model_statistics_date_year
        ORDER BY v.st_models_name,st_model_statistics.st_model_statistics_date_year;              
    END IF;
	IF v_type = 'new_models_with_concurency_per_month_all' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_model = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.model'));
		SELECT SUM(st_model_statistics.st_model_statistics_count) as 's' INTO v_sum FROM
			st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
			WHERE st_models_name = v_model
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_models_name;
		SELECT st_groups_name into v_group FROM st_model_statistics
			JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_groups ON st_models_groups_id = st_groups.id
			WHERE st_models_name = v_model 
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_groups_name
			ORDER BY SUM(st_model_statistics.st_model_statistics_count) DESC LIMIT 1;
            
		SELECT st_models_name as 'lbl', SUM(st_model_statistics_count) as 's', st_model_statistics_date_year,st_model_statistics_date_month FROM st_model_statistics
        JOIN st_models ON st_models.id = st_model_statistics_models_id
        WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
		AND
		st_models.st_models_name IN
			(SELECT A.st_models_name FROM (
				(SELECT st_models_name,  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
					st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
                    JOIN st_groups ON st_groups.id = st_models.st_models_groups_id
					WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
					AND st_groups_name = v_group
                    GROUP BY st_models_name
					HAVING s <= v_sum ORDER BY s DESC LIMIT 4)
				UNION ALL (
				SELECT st_models_name,  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
					st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
                    JOIN st_groups ON st_groups.id = st_models.st_models_groups_id
					WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
					AND st_groups_name = v_group
                    GROUP BY st_models_name
					HAVING s > v_sum ORDER BY s ASC LIMIT 1)
                    )
				as A)
		GROUP BY st_models.st_models_name,st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
        ORDER BY st_models.st_models_name,st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;            
    END IF;
	IF v_type = 'new_models_with_concurency_per_year_all' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_model = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.model'));
		SELECT SUM(st_model_statistics.st_model_statistics_count) as 's' INTO v_sum FROM
			st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
			WHERE st_models_name = v_model
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_models_name;
		SELECT st_groups_name into v_group FROM st_model_statistics
			JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_groups ON st_models_groups_id = st_groups.id
			WHERE st_models_name = v_model 
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_groups_name
			ORDER BY SUM(st_model_statistics.st_model_statistics_count) DESC LIMIT 1;
            
		SELECT st_models_name as 'lbl', SUM(st_model_statistics_count) as 's', st_model_statistics_date_year FROM st_model_statistics
        JOIN st_models ON st_models.id = st_model_statistics_models_id
        WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
		AND
		st_models.st_models_name IN
			(SELECT A.st_models_name FROM (
				(SELECT st_models_name,  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
					st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
                    JOIN st_groups ON st_groups.id = st_models.st_models_groups_id
					WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
					AND st_groups_name = v_group
                    GROUP BY st_models_name
					HAVING s <= v_sum ORDER BY s DESC LIMIT 4)
				UNION ALL (
				SELECT st_models_name,  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
					st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
                    JOIN st_groups ON st_groups.id = st_models.st_models_groups_id
					WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
					AND st_groups_name = v_group
                    GROUP BY st_models_name
					HAVING s > v_sum ORDER BY s ASC LIMIT 1)
                    )
				as A)
		GROUP BY st_models.st_models_name, st_model_statistics.st_model_statistics_date_year
        ORDER BY st_models.st_models_name,st_model_statistics.st_model_statistics_date_year;            
    END IF;
	IF v_type = 'new_groups_per_month' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_group = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.group'));
		SELECT SUM(st_model_statistics.st_model_statistics_count), st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics.st_model_statistics_models_id
			JOIN st_groups ON st_groups.id = st_models.st_models_groups_id
			WHERE st_groups.st_groups_name = v_group
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
			ORDER BY st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;
    END IF;
	IF v_type = 'new_fuels_per_month' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_fuel = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.fuel'));
		SELECT SUM(st_model_statistics.st_model_statistics_count), st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month FROM st_model_statistics
			JOIN st_fuel ON st_fuel.id = st_model_statistics_fuel_id
			WHERE st_fuel.st_fuel_name = v_fuel
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
			ORDER BY st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;
    END IF;
	IF v_type = 'new_brands_per_month' OR v_type = 'new_brands_of_brand_n_concurency_per_month' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
		SELECT SUM(st_model_statistics.st_model_statistics_count) as 's', st_model_statistics.st_model_statistics_date_year as 'year', st_model_statistics.st_model_statistics_date_month as 'month' FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics.st_model_statistics_models_id
			JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
			WHERE st_brands.st_brands_name = v_brand
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
			ORDER BY st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;
    END IF;
	IF v_type = 'new_models_of_model_fuels_per_month' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_model = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.model'));
        SET v_fuel = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.fuel'));
            
		SELECT st_groups_name into v_group FROM st_model_statistics
			JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_groups ON st_models_groups_id = st_groups.id
			WHERE st_models_name = v_model 
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_groups_name
			ORDER BY SUM(st_model_statistics.st_model_statistics_count) DESC LIMIT 1;

		SELECT st_model_statistics.st_model_statistics_count as 's', st_model_statistics.st_model_statistics_date_year as 'year', st_model_statistics.st_model_statistics_date_month as 'month' FROM st_model_statistics
			JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_groups ON st_models_groups_id = st_groups.id
			JOIN st_fuel ON st_fuel.id = st_model_statistics_fuel_id
			WHERE st_groups.st_groups_name = v_group AND st_models.st_models_name = v_model  AND st_fuel.st_fuel_name = v_fuel
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			ORDER BY st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;
    END IF;
	IF v_type = 'new_models_of_model_fuels_per_month_all' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_model = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.model'));

		SELECT st_fuel.st_fuel_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's', st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month FROM st_model_statistics
			JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_fuel ON st_fuel.id = st_model_statistics_fuel_id
			WHERE st_models.st_models_name = v_model
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_fuel.st_fuel_name, st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month
            ORDER BY st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;
    END IF;
	IF v_type = 'new_models_of_model_fuels_per_year_all' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_model = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.model'));

		SELECT st_fuel.st_fuel_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's', st_model_statistics.st_model_statistics_date_year FROM st_model_statistics
			JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_fuel ON st_fuel.id = st_model_statistics_fuel_id
			WHERE st_models.st_models_name = v_model
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_fuel.st_fuel_name, st_model_statistics.st_model_statistics_date_year
            ORDER BY st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;
    END IF;
	IF v_type = 'new_models_of_model_category_n_concurency_per_month' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_model = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.model'));
            
		SELECT st_groups_name into v_group FROM st_model_statistics
			JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_groups ON st_models_groups_id = st_groups.id
			WHERE st_models_name = v_model
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_groups_name
			ORDER BY SUM(st_model_statistics.st_model_statistics_count) DESC LIMIT 1;
            
		SELECT SUM(st_model_statistics.st_model_statistics_count), st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics.st_model_statistics_models_id
			JOIN st_groups ON st_models_groups_id = st_groups.id
			WHERE st_models.st_models_name = v_model AND st_groups.st_groups_name = v_group
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
			ORDER BY st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;
    END IF;
	IF v_type = 'new_models_total_score' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_model = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.model'));
            
		SELECT SUM(st_model_statistics_count) INTO v_sum FROM st_model_statistics
        JOIN st_models ON st_models.id = st_model_statistics_models_id
        WHERE st_models_name = v_model
		AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
        GROUP BY st_models_name; 
        
		(SELECT st_models_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's' FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics.st_model_statistics_models_id
			WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_models_name ORDER BY s DESC LIMIT 4)
		UNION
        SELECT v_model as 'lbl', v_sum as 's'
		ORDER BY s DESC;
    END IF;
	IF v_type = 'new_brands_total_score' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
            
		SELECT SUM(st_model_statistics_count) INTO v_sum FROM st_model_statistics
        JOIN st_models ON st_models.id = st_model_statistics_models_id
		JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
        WHERE st_brands_name = v_brand
		AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
        GROUP BY st_brands_name; 
        
		(SELECT st_brands_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's' FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics.st_model_statistics_models_id
			JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
			WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_brands_name ORDER BY s DESC LIMIT 4)
		UNION
        SELECT v_brand as 'lbl', v_sum as 's'
		ORDER BY s DESC;
    END IF;
    IF v_type = 'new_brands_of_brand_n_concurency' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
        
		SELECT SUM(st_model_statistics.st_model_statistics_count) as 's' INTO v_sum FROM
			st_model_statistics
            JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
			WHERE st_brands.st_brands_name = v_brand
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_brands_name;
        
        SELECT A.lbl, A.s FROM (
			(SELECT st_brands_name as 'lbl',  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
				st_model_statistics 
                JOIN st_models ON st_model_statistics_models_id = st_models.id
				JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
				WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
				GROUP BY st_brands_name
				HAVING s <= v_sum ORDER BY s DESC LIMIT 4)
			UNION ALL (
			SELECT st_brands_name as 'lbl',  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
				st_model_statistics
                JOIN st_models ON st_model_statistics_models_id = st_models.id
				JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
				WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
				GROUP BY st_brands_name
				HAVING s > v_sum ORDER BY s ASC LIMIT 1)) as A
				ORDER BY A.s DESC;
    END IF;
    IF v_type = 'new_brands_with_concurency_per_month_all' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
        
		SELECT SUM(st_model_statistics.st_model_statistics_count) as 's' INTO v_sum FROM
			st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_brands ON st_models_brands_id = st_brands.id
			WHERE st_brands_name = v_brand
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_brands_name;
            
		SELECT st_brands_name as 'lbl', SUM(st_model_statistics_count) as 's', st_model_statistics_date_year,st_model_statistics_date_month FROM st_model_statistics
        JOIN st_models ON st_models.id = st_model_statistics_models_id
		JOIN st_brands ON st_brands.id = st_models_brands_id
        WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
		AND
		st_brands.st_brands_name IN
			(SELECT A.st_brands_name FROM ( -- nemusi byt SUM v SELECTU, staci v HAVING
				(SELECT st_brands_name,  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
					st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
					JOIN st_brands ON st_brands.id = st_models_brands_id
					WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
                    GROUP BY st_brands_name
					HAVING s <= v_sum ORDER BY s DESC LIMIT 4)
				UNION ALL (
				SELECT st_brands_name,  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
					st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
					JOIN st_brands ON st_brands.id = st_models_brands_id
					WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
                    GROUP BY st_brands_name
					HAVING s > v_sum ORDER BY s ASC LIMIT 1)
                    )
				as A)
		GROUP BY st_brands.st_brands_name,st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
        ORDER BY st_brands.st_brands_name,st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;   
    END IF;
    IF v_type = 'new_brands_with_concurency_per_year_all' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
        
		SELECT SUM(st_model_statistics.st_model_statistics_count) as 's' INTO v_sum FROM
			st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_brands ON st_models_brands_id = st_brands.id
			WHERE st_brands_name = v_brand
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_brands_name;
            
		SELECT st_brands_name as 'lbl', SUM(st_model_statistics_count) as 's', st_model_statistics_date_year,st_model_statistics_date_month FROM st_model_statistics
        JOIN st_models ON st_models.id = st_model_statistics_models_id
		JOIN st_brands ON st_brands.id = st_models_brands_id
        WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
		AND
		st_brands.st_brands_name IN
			(SELECT A.st_brands_name FROM ( -- nemusi byt SUM v SELECTU, staci v HAVING
				(SELECT st_brands_name,  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
					st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
					JOIN st_brands ON st_brands.id = st_models_brands_id
					WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
                    GROUP BY st_brands_name
					HAVING s <= v_sum ORDER BY s DESC LIMIT 4)
				UNION ALL (
				SELECT st_brands_name,  SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
					st_model_statistics JOIN st_models ON st_model_statistics_models_id = st_models.id
					JOIN st_brands ON st_brands.id = st_models_brands_id
					WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
                    GROUP BY st_brands_name
					HAVING s > v_sum ORDER BY s ASC LIMIT 1)
                    )
				as A)
		GROUP BY st_brands.st_brands_name, st_model_statistics.st_model_statistics_date_year
        ORDER BY st_brands.st_brands_name,st_model_statistics.st_model_statistics_date_year;   
    END IF;
	IF v_type = 'new_brands_of_brand_fuels' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
            
		SELECT st_fuel_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
			st_model_statistics 
			JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
            JOIN st_fuel ON st_fuel.id = st_model_statistics_fuel_id
			WHERE st_brands_name = v_brand AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to) 
			GROUP BY st_fuel_name
			ORDER BY s DESC LIMIT v_lim;
    END IF;
	IF v_type = 'new_brands_models_of_brand' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
            
		SELECT st_models_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
			st_model_statistics 
			JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
			WHERE st_brands_name = v_brand AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to) 
			GROUP BY st_models_name
			ORDER BY s DESC LIMIT v_lim;
    END IF;
	IF v_type = 'new_brands_groups_of_brand' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
            
		SELECT st_groups_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's' FROM
			st_model_statistics 
			JOIN st_models ON st_model_statistics_models_id = st_models.id
			JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
			JOIN st_groups ON st_groups.id = st_models_groups_id
			WHERE st_brands_name = v_brand AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to) 
			GROUP BY st_groups_name
			ORDER BY s DESC LIMIT v_lim;
    END IF;
	IF v_type = 'new_brands_of_brand_fuels_per_month' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
        SET v_fuel = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.fuel'));
            
		SELECT SUM(st_model_statistics.st_model_statistics_count), st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics.st_model_statistics_models_id
			JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
            JOIN st_fuel ON st_fuel.id = st_model_statistics_fuel_id
			WHERE st_brands.st_brands_name = v_brand AND st_fuel.st_fuel_name = v_fuel
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
			ORDER BY st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;
    END IF;
	IF v_type = 'new_brands_of_brand_fuels_per_month_all' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
            
		SELECT st_fuel.st_fuel_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's', st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics.st_model_statistics_models_id
			JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
            JOIN st_fuel ON st_fuel.id = st_model_statistics_fuel_id
			WHERE st_brands.st_brands_name = v_brand
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY lbl, st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
			ORDER BY lbl, st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;
    END IF;
	IF v_type = 'new_brands_of_brand_fuels_per_year_all' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
            
		SELECT st_fuel.st_fuel_name as 'lbl', SUM(st_model_statistics.st_model_statistics_count) as 's', st_model_statistics.st_model_statistics_date_year FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics.st_model_statistics_models_id
			JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
            JOIN st_fuel ON st_fuel.id = st_model_statistics_fuel_id
			WHERE st_brands.st_brands_name = v_brand
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY lbl, st_model_statistics.st_model_statistics_date_year
			ORDER BY lbl, st_model_statistics.st_model_statistics_date_year;
    END IF;
	IF v_type = 'new_brands_groups_of_brand_per_month' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand'));
        SET v_group = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.group'));
            
		SELECT SUM(st_model_statistics.st_model_statistics_count), st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics.st_model_statistics_models_id
			JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
			JOIN st_groups ON st_groups.id = st_models_groups_id
			WHERE st_brands.st_brands_name = v_brand AND st_groups.st_groups_name = v_group
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
			GROUP BY st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
			ORDER BY st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;
    END IF;
	IF v_type = 'new_brands_groups_of_brand_per_month_all' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand')); 

		SELECT g.st_groups_name as 'lbl', SUM(st_model_statistics_count) as 's', st_model_statistics_date_year,st_model_statistics_date_month FROM st_model_statistics
        JOIN st_models as v ON v.id = st_model_statistics_models_id
        JOIN st_groups as g ON g.id = v.st_models_groups_id
        JOIN st_brands ON st_brands.id = v.st_models_brands_id
        INNER JOIN (SELECT st_groups_name FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics_models_id
			JOIN st_brands ON st_brands.id = st_models_brands_id
			JOIN st_groups ON st_groups.id = st_models_groups_id
			WHERE st_brands_name = v_brand 
            AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
            GROUP BY st_groups_name
			ORDER BY SUM(st_model_statistics_count) DESC LIMIT 5) as A ON g.st_groups_name = A.st_groups_name
		WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
		GROUP BY g.st_groups_name,st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
        ORDER BY g.st_groups_name,st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;   
    END IF;
	IF v_type = 'new_brands_groups_of_brand_per_year_all' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand')); 

		SELECT g.st_groups_name as 'lbl', SUM(st_model_statistics_count) as 's', st_model_statistics_date_year,st_model_statistics_date_month FROM st_model_statistics
        JOIN st_models as v ON v.id = st_model_statistics_models_id
        JOIN st_groups as g ON g.id = v.st_models_groups_id
        JOIN st_brands ON st_brands.id = v.st_models_brands_id
        INNER JOIN (SELECT st_groups_name FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics_models_id
			JOIN st_brands ON st_brands.id = st_models_brands_id
			JOIN st_groups ON st_groups.id = st_models_groups_id
			WHERE st_brands_name = v_brand 
            AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
            GROUP BY st_groups_name
			ORDER BY SUM(st_model_statistics_count) DESC LIMIT 5) as A ON g.st_groups_name = A.st_groups_name
		WHERE MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
		GROUP BY g.st_groups_name, st_model_statistics.st_model_statistics_date_year
        ORDER BY g.st_groups_name,st_model_statistics.st_model_statistics_date_year;   
    END IF;
	IF v_type = 'new_brands_colors' THEN
		SET v_lim :=
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.lim'));
        SET v_brand = 		
			JSON_UNQUOTE(JSON_EXTRACT(p_json, '$.brand')); 

		SELECT st_colours.st_colours_name as 'lbl', SUM(st_brand_colour_statistics.st_brand_colour_statistics_count) as 's' FROM st_brand_colour_statistics
        JOIN st_colours ON st_colours.id = st_brand_colour_statistics.st_brand_colour_statistics_colours_id
        JOIN st_brands ON st_brands.id = st_brand_colour_statistics.st_brand_colour_statistics_brands_id
        WHERE st_brands.st_brands_name = v_brand
		AND MAKEDATE(st_brand_colour_statistics_date_year,st_brand_colour_statistics_date_month) BETWEEN MAKEDATE(v_year_from, v_month_from) AND MAKEDATE(v_year_to, v_month_to)
		GROUP BY st_colours.st_colours_name
        ORDER BY s DESC LIMIT v_lim;
    END IF;
END//

DELETE FROM st_fuel WHERE st_fuel_name = 'Celkem'

DELETE FROM st_model_statistics where st_model_statistics_date_year = 2020
WHERE st_fuel_name = 'Celkem'


		SELECT v.st_models_name as 'lbl', SUM(st_model_statistics_count) as 's', st_model_statistics_date_year,st_model_statistics_date_month FROM st_model_statistics
        JOIN st_models as v ON v.id = st_model_statistics_models_id
        JOIN st_brands ON st_brands.id = v.st_models_brands_id
        INNER JOIN (SELECT st_models_name FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics_models_id
			JOIN st_brands ON st_brands.id = st_models_brands_id
			WHERE st_brands_name = 'Fiat'
            GROUP BY st_models_name
			ORDER BY SUM(st_model_statistics_count) DESC LIMIT 5) as A ON v.st_models_name = A.st_models_name
		GROUP BY v.st_models_name,st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
        ORDER BY v.st_models_name,st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;  



select * from st_fuel
SELECT st_models_name, st_fuel_name,st_model_statistics_count from st_model_statistics 
			JOIN st_models ON st_models.id = st_model_statistics.st_model_statistics_models_id
			JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
			JOIN st_groups ON st_groups.id = st_models_groups_id
            JOIN st_fuel ON st_fuel.id = st_model_statistics_fuel_id
			WHERE st_model_statistics_date_year = 2020

            
		SELECT SUM(st_model_statistics.st_model_statistics_count), st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month FROM st_model_statistics
			JOIN st_models ON st_models.id = st_model_statistics.st_model_statistics_models_id
			JOIN st_brands ON st_brands.id = st_models.st_models_brands_id
			JOIN st_groups ON st_groups.id = st_models_groups_id
            JOIN st_fuel ON st_fuel.id = st_model_statistics_fuel_id
			WHERE st_brands.st_brands_name = 'Renault' AND st_groups.st_groups_name = 'OA Paliva za měsíc Malé' AND NOT st_fuel.st_fuel_name = 'Celkem'
			AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(2010, 1) AND MAKEDATE(2010, 3)
			GROUP BY st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
			ORDER BY st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;

CALL selectNewBrands('{"type":"new_models_per_month","model":"Porsche Boxster","year_from":"2008","month_from":"1","year_to":"2008","month_to":"12","lim":"5"}')

		SELECT SUM(st_model_statistics.st_model_statistics_count), st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month FROM st_model_statistics
		JOIN st_fuel ON st_fuel.id = st_model_statistics_fuel_id
		WHERE st_fuel.st_fuel_name = 'Benzin'
        AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(2010, 1) AND MAKEDATE(2010, 3)
		GROUP BY st_model_statistics.st_model_statistics_date_month, st_model_statistics.st_model_statistics_date_year
		ORDER BY st_model_statistics.st_model_statistics_date_year, st_model_statistics.st_model_statistics_date_month;

        SELECT * FROM statistic1.st_model_statistics
        join st_models on st_models.id = st_model_statistics_models_id
        join st_groups on st_models.st_models_groups_id = st_groups.id
        WHERE st_models.st_models_name = 'Škoda FABIA'
        
        CALL selectNewBrands('{"type":"new_model_of_category","group":"OA Paliva za měsíc Malé","year_from":"2008","month_from":"1","year_to":"2010","month_to":"1","lim":"5"}')
   select st_brands_name from st_brands WHERE st_brands_name LIKE "skod%"    
CALL selectNewBrands('{"type":"new_model_of_category","group":"OA Paliva za měsíc Malé","year_from":"2008","month_from":"1","year_to":"2010","month_to":"1","lim":"5"}')

		SELECT st_groups.st_groups_name as 'lbl',SUM(st_model_statistics_count) as 's' from st_model_statistics
        JOIN st_models ON st_model_statistics_models_id = st_models.id
        JOIN st_groups ON st_models_groups_id = st_groups.id
		WHERE
        st_models_name = 'FIAT 500' 
		AND MAKEDATE(st_model_statistics_date_year,st_model_statistics_date_month) BETWEEN MAKEDATE(2008, 1) AND MAKEDATE(2010, 1)
		GROUP BY st_models_groups_id
		ORDER BY st_groups_name LIMIT 5;