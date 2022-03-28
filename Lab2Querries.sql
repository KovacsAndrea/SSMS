--So the way this works: We're on a farm with many many parcells. On this farm there are 4 major projects: farm shops,
-- chicken pens, planting and harvesting, and shepherding. Each of the last 3 is located on a parcell 
-- many building materials were used on building many farm shops
-- many building materials were used on building many chicken pens 
-- many pieces of equipment were used with the planting and harvesting projects
-- many farmers helped with many planting and harvesting projects
-- each planting and harvesting project has one specific plant assigned
-- many shepherders helped with the shepherding project
USE [Clarkson's Farm Activities2]

 



--a. 2 queries with the union operation; use UNION [ALL] and OR;
--FIND THE ID OF THE NAMES AND EMAILS OF THE FARMERS THAT WERE INVOLVED IN PLANTING COTTON OR BARLEY
SELECT DISTINCT QF.farmer_name, QF.email
FROM qualified_farmer QF 
	INNER JOIN ph_project PP ON PP.qfid = QF.qfid
	INNER JOIN planting_harvesting PH ON PH.phid = PP.phid
WHERE PH.phid IN(
	SELECT PH.phid
	FROM planting_harvesting PH, plant P
	WHERE PH.plant_id = P.plantid AND P.plant_name = 'Cotton'
	UNION ALL
	SELECT PH.phid
	FROM planting_harvesting PH, plant P
	WHERE PH.plant_id = P.plantid AND P.plant_name = 'Barley'
)

--FIND THE ID OF THE NAMES AND EMAILS OF THE FARMERS THAT WERE INVOLVED IN PLANTING WHEAT OR POTATOES
SELECT DISTINCT QF.farmer_name, QF.email
FROM qualified_farmer QF 
	INNER JOIN ph_project PP ON PP.qfid = QF.qfid
	INNER JOIN planting_harvesting PH ON PH.phid = PP.phid
WHERE PH.phid IN(
	SELECT PH.phid
	FROM planting_harvesting PH, plant P
	WHERE PH.plant_id = P.plantid AND (P.plant_name = 'Wheat' OR P.plant_name = 'Potatoes')
)


 


 
--b. 2 queries with the intersection operation; use INTERSECT and IN;
--FIND THE NAME OF THE SHEPHERDERS THAT HELPED IN SHEPHERDING PROJECTS WITH MORE THAT 60 SHEEP AND HAVE A SALARY OVER 3800
SELECT DISTINCT S.shepherder_name
FROM shepherder S, helped_with HW, shepherding SH
WHERE S.shpid = HW.shepherder_id AND HW.shepherding_id = SH.shid AND SH.no_sheep > 60
INTERSECT
SELECT S2.shepherder_name
FROM shepherder S2
WHERE S2.salary > 3800

--FIND THE ID AND PLANT NAME OF THE PROJECTS LOCATED ON PARCELLS LARGER THAT 600 SQARE METERS
SELECT DISTINCT PH.phid, P.plant_name
FROM planting_harvesting PH, plant P
WHERE PH.plant_id = P.plantid AND PH.parcell_id IN(
	SELECT PA.parid
	FROM parcell PA
	where PA.parcell_size > 600
)





 
--c. 2 queries with the difference operation; use EXCEPT and NOT IN;
--FIND THE PARCELL WHERE NO ACTIVITIES ARE TAKING PLACE
SELECT *
FROM parcell P1
WHERE P1.parid IN(
	SELECT P.parid
	FROM parcell P
	EXCEPT
		SELECT DISTINCT CP.chpid
		FROM chicken_pen CP
	EXCEPT
		SELECT DISTINCT PH.parcell_id
		FROM planting_harvesting PH
	EXCEPT
		SELECT DISTINCT S.parcell_id
		FROM shepherding S
)

--FIND THE ID OF THE SHEPHERDING PROJECTS IN WHICH NO SHEPHERDER WAS INVOLVED
SELECT SH.shid
FROM shepherding SH
WHERE SH.shid NOT IN (
	SELECT DISTINCT HW.shepherding_id
	FROM helped_with HW
)






--d. 4 queries with INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL JOIN (one query per operator); 
--one query will join at least 3 tables, while another one will join at least two many-to-many relationships;

--EACH PIECE OF EQUIPMENT THAT IS NOT BOUGHT WILL BE RENTED FROM THE EARLIEST DATE UNTIL THE LATEST DATE OF ALL THE PROJECTS IT IS INVOLVED IN
--FIND THE ID, NAME, RENT DATE, RETURN DATE, TIME INTERVAL IN DAYS, AND THE AMMOUNT IN COST TO RENT THEM
SELECT EQ.eq_name AS equipment_id, 
	MIN(PH.planting_date)  AS rent_date,
	MAX(PH.harvesting_date) AS return_date, 
	-1 * DATEDIFF(day, MAX(PH.harvesting_date), MIN(PH.planting_date)) AS interval_in_days,
	EQ.rent_price_per_day * DATEDIFF(day, MAX(PH.harvesting_date), MIN(PH.planting_date)) * -1 AS price
FROM equipment EQ
INNER JOIN project_details PD ON EQ.eqid = PD.equipment_id 
INNER JOIN planting_harvesting PH ON PH.phid = PD.ph_project
WHERE EQ.is_rented = 1
GROUP BY EQ.eqid, EQ.eq_name, EQ.rent_price_per_day

--ONLY THE FARMERS WHO HAVE A DRIVING PERMIT WERE ABLE TO DRIVE THE EQUIPMENT USED IN THE PROJECTS THEY WERE INVOLVED IN.
--FIND THE NAME AND EMAIL OF THOSE FARMERS AND THE EQUIPMENT THEY DROVE
SELECT DISTINCT EQ.eq_name, QF.farmer_name, QF.email
FROM qualified_farmer QF
FULL OUTER JOIN ph_project PP ON QF.qfid = pp.qfid
FULL OUTER JOIN planting_harvesting PH ON PH.phid = PP.phid
FULL OUTER JOIN project_details PD ON PD.ph_project = PH.phid
FULL OUTER JOIN equipment EQ ON EQ.eqid = PD.equipment_id
WHERE QF.driving_permit = 1
GROUP BY EQ.eq_name, QF.farmer_name, QF.email

--FIND THE NAME, SIZE AND ID OF THE PARCELLS WHERE THERE ARE ONLY CHICKEN PENS AND SHEPHERDING GOING ON
SELECT P.parid, P.parcell_name, P.parcell_size
FROM parcell P
RIGHT JOIN chicken_pen CP ON CP.parcell_id = P.parid
INTERSECT
SELECT P2.parid, P2.parcell_name, P2.parcell_size
FROM parcell P2
RIGHT JOIN shepherding SH ON SH.parcell_id = P2.parid

--FIND THE NAME, SIZE AND ID OF THE PARCELLS WHERE THERE IS AT LEAST ONE ACTIVITY GOING ON
SELECT P.parid, P.parcell_name, P.parcell_size
FROM parcell P
JOIN chicken_pen CP ON CP.parcell_id = P.parid
INTERSECT
SELECT P2.parid, P2.parcell_name, P2.parcell_size
FROM parcell P2
LEFT JOIN shepherding SH ON SH.parcell_id = P2.parid
INTERSECT
SELECT P3.parid, P3.parcell_name, P3.parcell_size
FROM parcell P3
LEFT JOIN planting_harvesting PH ON PH.parcell_id = P3.parid






--e. 2 queries with the IN operator and a subquery in the WHERE clause; 
--in at least one case, the subquery should include a subquery in its own WHERE clause;
--FIND PARCELLS WITH THE CHICKEN PENS THAT WERE BUILT WITH BRICKS
SELECT *
FROM parcell P
WHERE P.parid IN(
	SELECT CP.parcell_id
	FROM chicken_pen CP
	WHERE CP.chpid IN (
		SELECT DISTINCT PP.chicken_pen_id
		FROM pen_project PP
		WHERE PP.building_material_id IN (
			SELECT M.mid
			FROM building_material M
			WHERE M.material_type = 'Brick'  
		)
	)
)

--FIND ALL PARCELLS WITH PALNTS thAT NEED DRY CONDITIONS FOR HARVESTING
SELECT *
FROM parcell PAR
WHERE PAR.parid IN(
	SELECT PH.parcell_id
	FROM planting_harvesting PH
	WHERE PH.plant_id IN (
		SELECT P.plantid
		FROM plant P
		WHERE P.needs_dry = 1 
	)
)







--f. 2 queries with the EXISTS operator and a subquery in the WHERE clause;
--FIND THE FARMERS WHO DID NOT HELP IN ANY PROJECT
SELECT *
FROM qualified_farmer QF
WHERE NOT EXISTS (
	SELECT DISTINCT PP.qfid
	FROM ph_project PP
	WHERE QF.qfid = PP.qfid
)

--FIND THE EQUIPMENT THAT WAS USED IN PLANTING COTTON
SELECT *
FROM equipment EQ
WHERE EXISTS (
	 SELECT eqid
	 FROM project_details PD
	 WHERE PD.equipment_id = EQ.eqid AND EXISTS (
		SELECT PH.phid
		FROM planting_harvesting PH
		WHERE PH.phid = PD.ph_project AND EXISTS (
			SELECT P.plantid
			FROM plant P
			WHERE P.plant_name = 'Cotton' AND PH.plant_id = P.plantid
		)
	)
)
ORDER BY rent_price_per_day 







--g. 2 queries with a subquery in the FROM clause;  
--FOR EACH BUILDING MATERIAL, FIND THE TOTAL QUANTITY THAT WAS USED IN BUILDING THE FARM SHOPS AND THE CHICKEN PENS 
SELECT m_id, m_name, MAX(partial_sum) AS total_quantity
FROM(
	SELECT M.mid AS m_id, M.material_type AS m_name, SUM(ISNULL( PP.quantity, 0)) + SUM(ISNULL ( S.quantity, 0)) as partial_sum
	FROM  pen_project PP 
	FULL OUTER JOIN building_material M on M.mid = PP.building_material_id
	FULL OUTER JOIN shop_project S ON S.building_material_id = M.mid
	GROUP BY M.mid, M.material_type
) AS T
GROUP BY m_id, m_name
ORDER BY total_quantity

--TOP 3 FOR ABOVE
SELECT TOP 3 m_id, m_name, MAX(partial_sum) AS total_quantity
FROM(
	SELECT M.mid AS m_id, M.material_type AS m_name, SUM(ISNULL( PP.quantity, 0)) + SUM(ISNULL ( S.quantity, 0)) as partial_sum
	FROM  pen_project PP 
	FULL OUTER JOIN building_material M on M.mid = PP.building_material_id
	FULL OUTER JOIN shop_project S ON S.building_material_id = M.mid
	GROUP BY M.mid, M.material_type
) AS T
GROUP BY m_id, m_name
ORDER BY total_quantity DESC

--FIND THE NUMBER OF WORKERS ON EACH PARCELL (FARMERS AND SHEPHERDERS)
SELECT parid, COUNT (parid) AS no_workers
FROM (
	SELECT P.parid 
	FROM parcell P
	INNER JOIN shepherding SH ON SH.parcell_id = P.parid
	INNER JOIN helped_with HW ON HW.shepherding_id = SH.shid
	INNER JOIN shepherder S ON S.shpid = HW.shepherder_id
	UNION ALL
	SELECT P2.parid 
	FROM parcell P2
	INNER JOIN planting_harvesting PH ON PH.parcell_id = P2.parid
	INNER JOIN ph_project PP ON PP.phid = PH.phid
	INNER JOIN qualified_farmer QF ON QF.qfid = PP.qfid
) AS T
GROUP BY parid
ORDER BY no_workers

--FIND THE PARCELL WITH THE MOST WORKERS
SELECT TOP 1 parid, COUNT (parid) AS no_workers
FROM (
	SELECT P.parid 
	FROM parcell P
	INNER JOIN shepherding SH ON SH.parcell_id = P.parid
	INNER JOIN helped_with HW ON HW.shepherding_id = SH.shid
	INNER JOIN shepherder S ON S.shpid = HW.shepherder_id
	UNION ALL
	SELECT P2.parid 
	FROM parcell P2
	INNER JOIN planting_harvesting PH ON PH.parcell_id = P2.parid
	INNER JOIN ph_project PP ON PP.phid = PH.phid
	INNER JOIN qualified_farmer QF ON QF.qfid = PP.qfid
) AS T
GROUP BY parid
ORDER BY no_workers DESC
 






--h. 4 queries with the GROUP BY clause, 3 of which also contain the HAVING clause; 
--2 of the latter will also have a subquery in the HAVING clause; use the aggregation operators: COUNT, SUM, AVG, MIN, MAX;
--FIND THE ID AND NAME OF THE SHEPHERDER WHO WORKED ON THE MOST SHEPHERDING PROJECTS, AND THE NO. OF PROJECTS
SELECT DISTINCT HW.shepherder_id, S.shepherder_name, COUNT (HW.shepherder_id) AS project_count
FROM helped_with HW, shepherder S
WHERE HW.shepherder_id = S.shpid
GROUP BY HW.shepherder_id, S.shepherder_name
HAVING COUNT (HW.shepherder_id) >= ALL (
	SELECT COUNT(HW2.shepherder_id)
	FROM helped_with HW2
	GROUP BY HW2.shepherder_id
)

--FIND THE FARM SHOP THAT WAS MOST EXPENSIVE TO BUILD AND ITS PRICE
SELECT FS1.fsid, FS1.shop_name, SUM ( SP1.quantity * B1.price_per_kg)
FROM farm_shop FS1, shop_project SP1, building_material B1
WHERE FS1.fsid = SP1.farm_shop_id AND SP1.building_material_id = B1.mid
GROUP BY FS1.fsid, FS1.shop_name
HAVING SUM ( SP1.quantity * B1.price_per_kg) >= ALL (
	SELECT SUM ( SP.quantity * B.price_per_kg) sum_column
	FROM farm_shop FS, shop_project SP, building_material B
	WHERE FS.fsid = SP.farm_shop_id AND SP.building_material_id = B.mid
	GROUP BY FS.fsid
)

--FIND THE AVERAGE COST OF BUILDING THE FARM SHOPS 
SELECT AVG (sum_column)
FROM(
	SELECT SUM ( SP.quantity * B.price_per_kg) AS sum_column
	FROM farm_shop FS, shop_project SP, building_material B
	WHERE FS.fsid = SP.farm_shop_id AND SP.building_material_id = B.mid
	GROUP BY FS.fsid
) T

--FIND THE QUANTITY OF THE BUILDING MATERIAL THAT WAS THE MOST USED
SELECT MAX(partial_sum) AS max_quantity
FROM(
	SELECT M.mid, SUM(ISNULL( PP.quantity, 0)) + SUM(ISNULL ( S.quantity, 0)) as partial_sum
	FROM  pen_project PP 
	FULL OUTER JOIN building_material M on M.mid = PP.building_material_id
	FULL OUTER JOIN shop_project S ON S.building_material_id = M.mid
	GROUP BY M.mid
) AS T

--FIND THE EQUIPMENT THAT HAS THE HIGHEST RENT PRICE AND IS FROM ENGLAND
SELECT *
FROM equipment EQ
WHERE EQ.is_rented = 1 AND EQ.country_origin = 'England' AND EQ.rent_price_per_day IN (
	SELECT MAX(EQ2.rent_price_per_day)
	FROM equipment EQ2
)

--FIND THE PLANT ON WHICH THE LEAST MONEY WAS SPENT
SELECT P1.plantid, P1.plant_name, SUM(P1.price * PA1.parcell_size) AS lowest_cost
FROM plant P1
INNER JOIN planting_harvesting PH1 ON PH1.plant_id = P1.plantid
INNER JOIN parcell PA1 ON PH1.parcell_id = PA1.parid
GROUP BY P1.plantid, P1.plant_name
HAVING SUM(P1.price * PA1.parcell_size) <= ALL (
	SELECT SUM(P.price * PA.parcell_size) AS total_cost
	FROM plant P
	INNER JOIN planting_harvesting PH ON PH.plant_id = P.plantid
	INNER JOIN parcell PA ON PH.parcell_id = PA.parid
	GROUP BY P.plantid
)

--FIND THE MINIMUM PROJECT LENGTH IN DAYS FOR EACH TYPE OF PLANT
SELECT P.plantid, P.plant_name, MIN(-1 * DATEDIFF(day, PH.harvesting_date, PH.planting_date)) AS date_diff
FROM planting_harvesting PH
INNER JOIN plant P ON p.plantid = PH.plant_id
GROUP BY P.plantid, P.plant_name







--i. 4 queries using ANY and ALL to introduce a subquery in the WHERE clause (2 queries per operator); 
--rewrite 2 of them with aggregation operators, and the other 2 with IN / [NOT] IN.
--FIND THE MOST EXPENSIVE EQUIPMENT THAT WAS USED IN PLANTING WHEAT

SELECT *
FROM equipment EQ
WHERE EQ.eqid IN(
	SELECT eqid
	FROM plant P
	INNER JOIN planting_harvesting PH ON PH.plant_id = P.plantid
	INNER JOIN project_details PD ON PD.ph_project = PH.phid
	INNER JOIN equipment EQ ON PD.equipment_id = EQ.eqid
	WHERE P.plant_name = 'Wheat'
) AND EQ.eqid >= ALL (
	SELECT eqid
	FROM plant P
	INNER JOIN planting_harvesting PH ON PH.plant_id = P.plantid
	INNER JOIN project_details PD ON PD.ph_project = PH.phid
	INNER JOIN equipment EQ ON PD.equipment_id = EQ.eqid
	WHERE P.plant_name = 'Wheat'
)

--FIND THE PARCELL WHERE THE MOST AMOUNT OF FERTILIZER WAS USED
SELECT PA1.parid, PA1.parcell_name, SUM(P1.fertilizer_quantity * PA1.parcell_size) AS fertilizer_quantity
FROM parcell PA1 
INNER JOIN planting_harvesting PH1 ON PH1.parcell_id = PA1.parid
INNER JOIN plant P1 ON P1.plantid = PH1.plant_id
GROUP BY PA1.parid, PA1.parcell_name
HAVING SUM(P1.fertilizer_quantity * PA1.parcell_size) >= ALL(
	SELECT SUM(P.fertilizer_quantity * PA.parcell_size) AS fertilizer_quantity
	FROM plant P
	INNER JOIN planting_harvesting PH ON PH.plant_id = P.plantid
	INNER JOIN parcell PA ON PH.parcell_id = PA.parid
	GROUP BY P.plantid
)

--FIND THE ID AND NUMBER OF SHEEP OF SHEPHERDING PROJECT WITH THE MOST SHEEP AND THE PARCELL WHERE IT IS LOCATED
SELECT SH.shid, SH.no_sheep, PA.parcell_name
FROM shepherding SH, parcell PA
WHERE PA.parid = SH.parcell_id AND SH.no_sheep = ANY (
	SELECT MAX(SH2.no_sheep)
	FROM shepherding SH2
)

SELECT SH.shid, SH.no_sheep, PA.parcell_name
FROM shepherding SH, parcell PA
WHERE PA.parid = SH.parcell_id AND SH.no_sheep IN (
	SELECT MAX(SH2.no_sheep)
	FROM shepherding SH2
)

--FIND THE ID AND NUMBER OF CHICKEN FROM THE PEN WITH THE MOST CHICKEN AND PARCELL NAME 
SELECT CP.chpid, CP.no_chicken, PA.parcell_name
FROM chicken_pen CP, parcell PA
WHERE PA.parid = CP.parcell_id AND CP.no_chicken = ANY (
	SELECT MAX(CP2.no_chicken)
	FROM chicken_pen CP2
)

SELECT CP.chpid, CP.no_chicken, PA.parcell_name
FROM chicken_pen CP, parcell PA
WHERE PA.parid = CP.parcell_id AND CP.no_chicken IN (
	SELECT MAX(CP2.no_chicken)
	FROM chicken_pen CP2
)

