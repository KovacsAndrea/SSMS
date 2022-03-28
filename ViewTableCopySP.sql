USE [Clarkson's Farm Activities2]
GO

DROP PROCEDURE usp_create_copy_of_table
GO

DROP PROCEDURE usp_drop_table
GO

DROP PROCEDURE usp_create_dummy_view
GO

DROP PROCEDURE usp_drop_view
GO

CREATE PROCEDURE usp_create_copy_of_table(@table_name VARCHAR(MAX))
AS
BEGIN
	DECLARE @new_table_name VARCHAR(MAX) = 'copy_' + @table_name
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(@new_table_name) and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		BEGIN
			RAISERROR('There is already a copy of the table "%s", named "%s"!',10,1, @table_name, @new_table_name)
			RETURN
		END
    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(@table_name) and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		BEGIN
			exec('
			SELECT *
			INTO ' + @new_table_name + '
			FROM chicken_pen
			')
		END
	ELSE 
		BEGIN
			RAISERROR('There is no table "%s" in the database!',10,1, @table_name)
			RETURN
		END
END 
GO

CREATE PROCEDURE usp_drop_table (@table_name VARCHAR(MAX))
AS
BEGIN
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(@table_name))
		BEGIN
			EXEC ('DROP TABLE [' + @table_name + ']') 
			PRINT('Removed table "' + @table_name + '".')
		END
	ELSE
		BEGIN
			RAISERROR('There is no table "%s" in the database!',10,1, @table_name)
			RETURN
		END
END
GO

EXEC usp_create_copy_of_table @table_name = 'chicken_pen'
GO
EXEC usp_create_copy_of_table @table_name = 'chicken_pen'
GO
--SELECT * 
--FROM copy_chicken_pen
EXEC usp_drop_table @table_name = 'copy_chicken_pen'
GO


CREATE PROCEDURE usp_create_dummy_view (@view_name VARCHAR(MAX))
AS
BEGIN
	DECLARE @new_view_name VARCHAR(MAX) = 'Dummy' + @view_name
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(@new_view_name))
		BEGIN
			RAISERROR('There is already a copy of the view "%s", named "%s"!',10,1, @view_name, @new_view_name)
			RETURN
		END
    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(@view_name))
		BEGIN
			exec('
			CREATE VIEW [' + @new_view_name + ']
			AS
				SELECT *
				FROM [' + @view_name + ']
			GO
			')
		END
	ELSE 
		BEGIN
			RAISERROR('There is no view "%s" in the database!',10,1, @view_name)
			RETURN
		END
END
GO

CREATE PROCEDURE usp_drop_view (@view_name VARCHAR(MAX))
AS
BEGIN
	IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(@view_name))
		BEGIN
			EXEC ('DROP VIEW [' + @view_name + ']') 
			PRINT('Removed view "' + @view_name + '".')
		END
	ELSE
		BEGIN
			RAISERROR('There is no view "%s" in the database!',10,1, @view_name)
			RETURN
		END
END
GO

CREATE VIEW [caca]
AS
	SELECT * 
	FROM [RentedEquipment]
GO
DROP VIEW [caca]

EXEC usp_create_dummy_view @view_name = 'RentedEquipment'
GO

SELECT * FROM DummyRentedEquipment

EXEC usp_drop_view @view_name = 'DummyRentedEquipment'

EXEC usp_create_dummy_view 'TotalQuantityOfEachMaterial'
SELECT * FROM DummyTotalQuantityOfEachMaterial
SELECT * FROM TotalQuantityOfEachMaterial

EXEC usp_drop_view @view_name = 'DummyTotalQuantityOfEachMaterial'
