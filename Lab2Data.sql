USE [Clarkson's Farm Activities2]

--insert data – for at least 4 tables; at least one statement should violate referential integrity constraints;
--update data – for at least 3 tables;
--delete data – for at least 2 tables.
--In the UPDATE / DELETE statements, use at least once: {AND, OR, NOT},  {<,<=,=,>,>=,<> }, IS [NOT] NULL, IN, BETWEEN, LIKE.




--DATA SECTION


select *
from chicken_pen

SET LANGUAGE English
INSERT INTO car_park (cpid, no_spaces) VALUES 
(1,30),
(2,40);

INSERT INTO cash_register (crid, serial_number) VALUES
(1,11111),
(2,22222),
(3,33333);

INSERT INTO shepherder (shpid, shepherder_name, salary, email) VALUES
(1,'Ellen Helliwell', 4200, 'eh@gmail.com'),
(2,'Georgia Craig', 3700, 'gc@gmail.com'),
(3,'Kevin Harrison', 3900, 'kh@gmail.com'),
(4,NULL, 3900, 'u1@gmail.com'),
(5,NULL, 3900, 'u2@gmail.com')

INSERT INTO plant (plantid, plant_name, needs_dry, fertilizer_quantity, price) VALUES
(1,'Rapeseed', 0, 4, 6),
(2,'Wheat', 1, 4, 4),
(3,'Barley', 1, 3, 7),
(4,'Potatoes', 0, 2, 5),
(5,'Carrots', 0, 1, 8),
(6,'Cotton', 1, 5, 10),
(7,'Wasabi', 0, 0, 50);

INSERT INTO equipment (eqid, eq_name, country_origin, rent_price_per_day, is_rented) VALUES
(1,'Lamborghini R8 Tractor', 'Germany', NULL, 0),
(2,'Cultivator', 'England', 80, 1),
(3,'Harvester', 'Scotland', 90, 1),
(4,'Sprayer','Ireland', 100, 1),
(5,'Row Crop Tractor', 'England',110, 1),
(6,'Cotton Stripper', 'Wales', 85, 1),
(7,'Cotton Picker', 'England', 91, 1);

INSERT INTO qualified_farmer (qfid, farmer_name, salary, email, driving_permit) VALUES
(1,'Kaleb Cooper', 3900, 'kc@ygmail.com', 1),
(2,'Gerald Cooper', 2400, 'gc@gmail.com', 1),
(3,'Charlie Ireland', 2500, 'ci@gmail.com', 0),
(4,'Lazy Bob', 100, 'lb@gmail.com', 0);

INSERT INTO parcell (parid, parcell_name, parcell_size) VALUES
(1,'BuryHill South', 1120),
(2,'Washpool', 512),
(3,'Banks', 1130),
(4,'Spittway', 808),
(5,'Hollow Back', 8188),
(6,'Road Field', 245),
(7,'BuryHill North', 1850),
(8,'Big Ground', 1549),
(9,'Wild Bird', 450),
(10,'Crownhill', 560),
(11,'Camp Field', 1246),
(12,'Quarry', 9844),
(13,'RandomParcell1', 1000),
(14,'RandomParcell2', 1000),
(15,'RandomParcell3', 1000),
(16,'Medow', 1100),
(17,'Big Medow', 1200);


INSERT INTO shepherding (shid, parcell_id, no_sheep, food_per_day) VALUES
(1, 1, 70, 140),
(2, 4, 50, 110),
(3, 5, 30, 80),
(4, 6, 66, 150);

INSERT INTO helped_with (shepherding_id, shepherder_id) VALUES
(1, 1),
(1, 2),
(1, 3),
(2, 1),
(2, 3),
(3, 1),
(3, 2);

INSERT INTO building_material (mid, material_type, price_per_kg) VALUES
(1, 'marble', 15),
(2, 'brick', 12),
(3, 'cement', 13),
(4, 'concrete', 14),
(5, 'wood', 10),
(6, 'glass', 20),
(7, 'sand', 18),
(8, 'clay', 9),
(9, 'foam', 5),
(10, 'metal', 17),
(11, 'plastics', 5),
(12, 'plastics', 6),
(13, 'plastic', 1),
(14, 'plastics', 8),
(15, 'plastic', 10000);

INSERT INTO farm_shop (fsid, shop_name, cash_register_id, car_park_id) VALUES
(1, 'FarmLand', 3, 2),
(2, 'Potatoes Heaven', 2, 1);
INSERT INTO farm_shop (fsid, shop_name, cash_register_id, car_park_id, shop_description) VALUES
(3, 'Diddly Squat Farm Shop', 1, 1, 'A very very cozy shop with local produce');

INSERT INTO shop_project (building_material_id, farm_shop_id, quantity) VALUES
(1, 1, 200),
(2, 1, 234),
(3, 1, 120),
(6, 1, 200),
(1, 2, 200),
(2, 2, 110),
(6, 2, 78),
(3, 3, 90),
(5, 3, 90),
(6, 3, 26);

INSERT INTO chicken_pen (chpid, no_chicken, parcell_id) VALUES
(1, 35, 2),
(2, 37, 3),
(3, 39, 4),
(4, 27, 4),
(5, 42, 6);

INSERT INTO pen_project (building_material_id, chicken_pen_id, quantity) VALUES
(2, 1, 25),
(5, 1, 20),
(8, 1, 30),
(7, 1, 13),
(11, 1, 13),
(3, 2, 13),
(5, 2, 12),
(8, 3, 14),
(2, 3, 34),
(5, 3, 25),
(7, 3, 25),
(3, 3, 25),
(3, 4, 25),
(5, 4, 25),
(8, 4, 25),
(2, 4, 22),
(5, 5, 22);

INSERT INTO planting_harvesting (phid, plant_id, planting_date, harvesting_date,parcell_id, seed_quantity) VALUES
(1, 1, '2019-02-22', '2019-10-22', 7, 100), --Rapeseed
(2, 2, '2019-03-29', '2019-08-20', 8, 230), --Wheat
(3, 3, '2019-01-30', '2019-09-10', 9, 500), --Barley
(4, 4, '2019-01-25', '2019-12-25', 10, 500), --Potatoes
(5, 6, '2019-01-26', '2019-11-20', 11, 250), --Cotton
(6, 7, '2019-03-26', '2019-12-20', 11, 20), --Wasabi
(7, 4, '2019-03-26', '2019-12-20', 16, 20), --Potatoes
(8, 4, '2019-03-26', '2019-12-10', 17, 20), --Potatoes
(9, 7, '2019-04-26', '2019-12-01', 4, 20); --Wasabi


INSERT INTO ph_project(phid, qfid) VALUES
(1, 1),
(1, 2),
(1, 3),

(2, 1),
(2, 2),

(3, 1),

(4, 1),

(5, 1),
(5, 3),
(8, 1),
(9, 1),
(9, 2),
(7, 1);

INSERT INTO project_details (ph_project, equipment_id) VALUES
(1, 1),
(1, 2),
(1, 3),

(2, 1),
(2, 2),
(2, 3),
(2, 5),

(3, 1),
(3, 2),
(3, 3),

(4, 1),
(4, 4),

(5, 6),
(5, 7);



--UPDATE SECTION




--SET THE PARCELL SIZE TO 2000 FOR ALL THE PARCELLS THAT HAVE 'RandomParcell' IN THE NAME
UPDATE parcell
set parcell_size = 2000
WHERE parcell_name LIKE 'RandomParcell_%'

--SET THE PRICE OF ALL TEH MATERIAL WITH THE TYPE PLASTICS AND HAVING THE PRICE BETWEEN 6 AND 10, TO 555
UPDATE building_material
SET price_per_kg = 555
WHERE material_type = 'plastics' AND price_per_kg BETWEEN 6 AND 10

--SET THE SALARY TO ZERO TO ALL THE SHEPHERDERS WHO DON'T HAVE A NAME
UPDATE shepherder
SET salary = 0
WHERE shepherder_name IS NULL

--ADD 1000 TO THE SALARY OF THE SHEPHERDERS WHO WORKED ON BOTH THE FIRST AND SECOND SHEPHERDING PROJECT
--SELECT *
--FROM shepherder S
--WHERE S.shpid IN(
--	SELECT H.shepherder_id
--	FROM helped_with H, helped_with H2
--	WHERE (H.shepherder_id = H2.shepherder_id AND H.shepherding_id = 'sh1') AND 
--		   (H.shepherder_id = H2.shepherder_id AND H2.shepherding_id = 'sh2'))

--SELECT S.shpid, S.shepherder_name
--FROM shepherder S, helped_with H
--WHERE (S.shpid = H.shepherder_id AND H.shepherding_id = 'sh1')
--INTERSECT(
--SELECT S2.shpid, S2.shepherder_name
--FROM shepherder S2, helped_with H2
--WHERE (S2.shpid = H2.shepherder_id AND H2.shepherding_id = 'sh2'))

UPDATE shepherder 
SET salary = salary + 1000
WHERE shpid IN(
	SELECT H.shepherder_id
	FROM helped_with H, helped_with H2
	WHERE (H.shepherder_id = H2.shepherder_id AND H.shepherding_id = 1) AND 
		   (H.shepherder_id = H2.shepherder_id AND H2.shepherding_id = 2)
)
------------------------------------------------------------------IGNORE THIS--------------------------------------------------------
-- FOR ALL EQUIPMENT THAT IS NOT BOUGHT (IS RENTED), SET THE RENT END DAY 5 DAYS AFTER THE LATEST FINISHING DATE
-- OF THE PLANTING AND HARVESTING IT IS INVOLVED IN. SET THE HIRE DATE 5 DAYS BEFORE THE START OF THE FIRST PROJECT IT IS INVOLVED IN

--SELECT *
--FROM equipment

--SELECT EQ.eqid AS equipment_id, MAX(PH.harvesting_date) AS latest_date, MIN(PH.planting_date)  AS earliest_date
--FROM equipment EQ, project_details PD, planting_harvesting PH
--WHERE EQ.eqid = PD.equipment_id AND PD.ph_project = PH.phid
--GROUP BY EQ.eqid

--SELECT *
--FROM equipment EQ FULL JOIN project_details PD ON EQ.eqid = PD.equipment_id FULL JOIN 
--		planting_harvesting PH ON PH.phid = PD.ph_project
--GROUP BY EQ.eqid

--UPDATE EQ
--SET EQ.eq_end_date = MAX (PH.harvesting_date)
--FROM equipment EQ
--INNER JOIN project_details PD ON EQ.eqid = PD.equipment_id 
--INNER JOIN planting_harvesting PH ON PH.phid = PD.ph_project
--GROUP BY EQ.eqid 
-----------------------------------------------------------------------------------------------------------------------------------


--THE WEATHER IS BAD AND SOME PLANTS CAN OLY BE HARVESTED DURING DRY WEATHER. EXTEND THE HARVESTING DATE WIHT 15 DAYS FOR
--ALL THE PROJECTS WITH THESE TYEPS OF PLANTS AND FOR ALL THE EQUIPMENT INVOLVED IN THIS PROJECTS 
--p2, p3 and p5 need dy weather 

UPDATE planting_harvesting
SET harvesting_date = DATEADD(day, 15, harvesting_date)
WHERE plant_id NOT IN(
	SELECT P.plantid
	FROM  plant P
	WHERE P.needs_dry = 0)

--SELECT * 
--FROM equipment

--UPDATE equipment
--SET eq_end_date = DATEADD(day, 15, eq_end_date)
--WHERE is_rented = 1 AND eqid IN (
--	SELECT DISTINCT PD.equipment_id
--	FROM project_details PD
--	WHERE PD.ph_project IN (
--		SELECT PH.phid
--		FROM planting_harvesting PH
--		WHERE PH.plant_id IN(
--			SELECT P.plantid
--			FROM  plant P
--			WHERE P.needs_dry = 1
--		)
--	)
--)

--SELECT * 
--FROM equipment




--DELETE SEECTION




DELETE FROM parcell
WHERE parcell_size = 2000

--DELETE THE BUILDING MATERIAL WITH THE HIGHERS PRICE AND LOWEST PRICE
DELETE FROM building_material 
WHERE price_per_kg >= ALL(
	SELECT B.price_per_kg
	FROM building_material B
)

DELETE FROM building_material
WHERE price_per_kg <= ALL(
	SELECT B.price_per_kg
	FROM building_material B
)

DELETE FROM building_material
WHERE price_per_kg = 555


DELETE FROM shepherder
WHERE salary = 0

--This will violate the PRIMARY KEY constraint. Duplicate keys cannot be inserted, and we already have the element
-- ('p1', 'Rapeseed') in the plant table.

--INSERT INTO plant (plantid, plant_name) VALUES
--('p1', 'Corn');

