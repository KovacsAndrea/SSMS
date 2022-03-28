DROP VIEW [RentedEquipment] 
GO
DROP VIEW [PHProjectsLengthinDays] 
GO
DROP VIEW [TotalQuantityOfEachMaterial] 
GO
DROP VIEW [NumberOfShepherdersOnEachParcel] 
GO
DROP VIEW [ParcelsWithChickenPens] 
GO
DROP VIEW [ParcelsWithShepherding] 
GO


CREATE VIEW [RentedEquipment]
AS
	SELECT eqid, eq_name, country_origin, rent_price_per_day
	FROM equipment
	WHERE is_rented = 1
GO
SELECT * FROM [RentedEquipment]
GO


CREATE VIEW [PHProjectsLengthinDays]
AS
	SELECT PH.phid, -1*DATEDIFF(day, PH.harvesting_date, PH.planting_date) AS project_length
	FROM planting_harvesting PH
GO
SELECT * FROM [PHProjectsLengthinDays]
GO


SELECT * FROM building_material
GO
CREATE VIEW [TotalQuantityOfEachMaterial]
AS
	SELECT m_id, m_name, MAX(partial_sum) AS total_quantity
	FROM(
		SELECT M.mid AS m_id, M.material_type AS m_name, SUM(ISNULL( PP.quantity, 0)) + SUM(ISNULL ( S.quantity, 0)) as partial_sum
		FROM  pen_project PP 
		FULL OUTER JOIN building_material M on M.mid = PP.building_material_id
		FULL OUTER JOIN shop_project S ON S.building_material_id = M.mid
		GROUP BY M.mid, M.material_type
	) AS T
	GROUP BY m_id, m_name
GO

SELECT * FROM [TotalQuantityOfEachMaterial]
GO

CREATE VIEW [NumberOfShepherdersOnEachParcel]
AS
	SELECT parid, COUNT (parid) AS no_workers
	FROM (
		SELECT P.parid 
		FROM parcell P
		INNER JOIN shepherding SH ON SH.parcell_id = P.parid
		INNER JOIN helped_with HW ON HW.shepherding_id = SH.shid
		INNER JOIN shepherder S ON S.shpid = HW.shepherder_id
	) AS T
	GROUP BY parid
GO

CREATE VIEW [ParcelsWithChickenPens]
AS
	SELECT *
	FROM parcell P
	RIGHT JOIN chicken_pen CP ON CP.parcell_id = P.parid
GO

CREATE VIEW [ParcelsWithShepherding]
AS
	SELECT *
	FROM parcell P
	RIGHT JOIN shepherding SH ON SH.parcell_id = P.parid
GO

SELECT * FROM [ParcelsWithShepherding]
GO

SELECT * FROM [NumberOfShepherdersOnEachParcel]
GO