USE [Clarkson's Farm Activities2]
GO

CREATE PROCEDURE usp_select_building_materials
AS 
BEGIN
	SELECT *
	FROM building_material
END 
GO

CREATE PROCEDURE usp_select_car_park
AS 
BEGIN
	SELECT *
	FROM car_park
END 
GO

CREATE PROCEDURE usp_select_cash_register
AS 
BEGIN
	SELECT *
	FROM cash_register
END 
GO

CREATE PROCEDURE usp_select_chicken_pen
AS 
BEGIN
	SELECT *
	FROM chicken_pen
END 
GO

CREATE PROCEDURE usp_select_equipment
AS 
BEGIN
	SELECT *
	FROM equipment
END 
GO

CREATE PROCEDURE usp_select_farm_shop
AS 
BEGIN
	SELECT *
	FROM farm_shop
END 
GO

CREATE PROCEDURE usp_select_helped_with
AS 
BEGIN
	SELECT *
	FROM helped_with
END 
GO

CREATE PROCEDURE usp_select_parcell
AS 
BEGIN
	SELECT *
	FROM parcell
END 
GO

CREATE PROCEDURE usp_select_pen_project
AS 
BEGIN
	SELECT *
	FROM pen_project
END 
GO

CREATE PROCEDURE usp_select_ph_project
AS 
BEGIN
	SELECT *
	FROM ph_project
END 
GO

CREATE PROCEDURE usp_select_plant
AS 
BEGIN
	SELECT *
	FROM plant
END 
GO

CREATE PROCEDURE usp_select_planting_harvesting
AS 
BEGIN
	SELECT *
	FROM planting_harvesting
END 
GO

CREATE PROCEDURE usp_select_project_details
AS 
BEGIN
	SELECT *
	FROM project_details
END 
GO

CREATE PROCEDURE usp_select_qualified_farmer
AS 
BEGIN
	SELECT *
	FROM qualified_farmer
END 
GO

CREATE PROCEDURE usp_select_shepherder
AS 
BEGIN
	SELECT *
	FROM shepherder
END 
GO

CREATE PROCEDURE usp_select_shepherding
AS 
BEGIN
	SELECT *
	FROM shepherding
END 
GO

CREATE PROCEDURE usp_select_shop_project
AS 
BEGIN
	SELECT *
	FROM shop_project
END 
GO

DROP PROCEDURE usp_select_building_materials
DROP PROCEDURE usp_select_car_park
DROP PROCEDURE usp_select_cash_register
DROP PROCEDURE usp_select_chicken_pen
DROP PROCEDURE usp_select_equipment
DROP PROCEDURE usp_select_farm_shop
DROP PROCEDURE usp_select_helped_with
DROP PROCEDURE usp_select_parcell
DROP PROCEDURE usp_select_pen_project
DROP PROCEDURE usp_select_ph_project
DROP PROCEDURE usp_select_plant
DROP PROCEDURE usp_select_planting_harvesting
DROP PROCEDURE usp_select_project_details
DROP PROCEDURE usp_select_qualified_farmer
DROP PROCEDURE usp_select_shepherder
DROP PROCEDURE usp_select_shepherding
DROP PROCEDURE usp_select_shop_project