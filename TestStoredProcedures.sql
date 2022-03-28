/*
Write SQL scripts that:
a. modify the type of a column;
b. add / remove a column;
c. add / remove a DEFAULT constraint;
d. add / remove a primary key;
e. add / remove a candidate key;
f. add / remove a foreign key;
g. create / drop a table.

For each of the scripts above, write another one that reverts the operation. 
Place each script in a stored procedure. Use a simple, intuitive naming convention.

Create a new table that holds the current version of the database schema. 
Simplifying assumption: the version is an integer number.

Write a stored procedure that receives as a parameter a version number and brings the database to that version.
*/

--a. modify the type of a column;
--Changing the type ofthe column price from table plant from INT to FLOAT
--/////////////////////////////////////////////////////////////////////////////
SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'plant'
AND COLUMN_NAME = 'price';
GO

CREATE PROCEDURE usp_modify_type_of_column_test
AS
BEGIN
	ALTER TABLE plant
		ALTER COLUMN price SMALLINT
END
GO
EXEC usp_modify_type_of_column_test
GO

SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'plant'
AND COLUMN_NAME = 'price';
GO

CREATE PROCEDURE usp_undo_modify_type_of_column_test
AS
BEGIN
	ALTER TABLE plant
		ALTER COLUMN price INT
END
GO
EXEC usp_undo_modify_type_of_column_test
GO

SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'plant'
AND COLUMN_NAME = 'price';
GO

DROP PROCEDURE usp_modify_type_of_column_test
GO
DROP PROCEDURE usp_undo_modify_type_of_column_test
GO

--b. add / remove a column;
--Add the column color to the table chicken pen
--/////////////////////////////////////////////////////////////////////////////
SELECT * 
FROM chicken_pen
GO

CREATE PROCEDURE usp_add_column_test
AS
BEGIN
	ALTER TABLE chicken_pen
		ADD color VARCHAR(50)
END
GO
EXEC usp_add_column_test
GO

SELECT * 
FROM chicken_pen
GO

CREATE PROCEDURE usp_undo_add_column_test
AS 
BEGIN
	ALTER TABLE chicken_pen
	DROP COLUMN color
END
GO
EXEC usp_undo_add_column_test
GO

SELECT * 
FROM chicken_pen
GO

DROP PROCEDURE usp_add_column_test
GO
DROP PROCEDURE usp_undo_add_column_test
GO


--c. add / remove a DEFAULT constraint;
--Remove the default constraint from the shop_description attribute in the table farm_shop
--////////////////////////////////////////////////////////////////////////////////////////
CREATE PROCEDURE usp_remove_default_constraint_test
AS
BEGIN
	ALTER TABLE farm_shop
		DROP CONSTRAINT DF_shop_description
END
GO
EXEC usp_remove_default_constraint_test
GO

CREATE PROCEDURE usp_undo_remove_default_constraint_test
AS
BEGIN
	ALTER TABLE farm_shop
		ADD CONSTRAINT DF_shop_description DEFAULT ('TBA') FOR shop_description
END
GO
EXEC usp_undo_remove_default_constraint_test
GO

DROP PROCEDURE usp_remove_default_constraint_test
GO
DROP PROCEDURE usp_undo_remove_default_constraint_test
GO

--d. add / remove a primary key;
--Remove the primary key constraint form the table shop_employee
--////////////////////////////////////////////////////////////////

CREATE PROCEDURE usp_remove_PK_test
AS
BEGIN
	ALTER TABLE farm_shop
		DROP CONSTRAINT FK_shop_employee
	ALTER TABLE shop_employee
		DROP CONSTRAINT PK_shop_employee
END
GO
EXEC usp_remove_PK_test
GO

CREATE PROCEDURE usp_undo_remove_PK_test
AS
BEGIN
	ALTER TABLE shop_employee
		ADD CONSTRAINT PK_shop_employee PRIMARY KEY (empid)
	ALTER TABLE farm_shop
		ADD CONSTRAINT FK_shop_employee FOREIGN KEY (employee_id) REFERENCES shop_employee(empid)
END
GO
EXEC usp_undo_remove_PK_test
GO

DROP PROCEDURE usp_remove_PK_test
GO
DROP PROCEDURE usp_undo_remove_PK_test
GO

--e. add / remove a candidate key;
--Remove the unique constraint on the CNP from table shop_employee
--////////////////////////////////////////////////////////////////
CREATE PROCEDURE usp_remove_candidate_key_test
AS
BEGIN
	ALTER TABLE shop_employee
		DROP CONSTRAINT UQ_cnp
END
GO

CREATE PROCEDURE usp_undo_remove_candidate_key_test
AS
BEGIN
	ALTER TABLE shop_employee
		ADD CONSTRAINT UQ_cnp UNIQUE (CNP)
END
GO


DROP PROCEDURE usp_remove_candidate_key_test
GO
DROP PROCEDURE usp_undo_remove_candidate_key_test
GO


--f. add / remove a foreign key;
--Remove the foreignk key for plant in the planting_harvesting table
--/////////////////////////////////////////////////////////////////
CREATE PROCEDURE usp_remove_FK_test
AS 
BEGIN
	ALTER TABLE planting_harvesting
		DROP CONSTRAINT FK_plant_id
END
GO
EXEC usp_remove_FK_test
GO

CREATE PROCEDURE usp_undo_remove_FK_test
AS
BEGIN
	ALTER TABLE planting_harvesting
	ADD CONSTRAINT FK_plant_id FOREIGN KEY (plant_id) REFERENCES plant(plantid)
END
GO
EXEC usp_undo_remove_FK_test
GO

DROP PROCEDURE usp_remove_FK_test
GO
DROP PROCEDURE usp_undo_remove_FK_test
GO

--g. create / drop a table.
--Remove the table shop_employee
CREATE PROCEDURE usp_drop_table_test
AS
BEGIN
	ALTER TABLE farm_shop
		DROP CONSTRAINT FK_shop_employee
	DROP TABLE shop_employee
END
GO
EXEC usp_drop_table_test
GO

CREATE PROCEDURE usp_undo_drop_table_test
AS
BEGIN
	CREATE TABLE shop_employee(
		empid VARCHAR(20),
		employee_name VARCHAR(30),
		employee_salary INT, 
		CNP VARCHAR(10),
		CONSTRAINT PK_shop_employee PRIMARY KEY (empid)
	)
	ALTER TABLE farm_shop
		ADD CONSTRAINT FK_shop_employee FOREIGN KEY (employee_id) REFERENCES shop_employee(empid)
END
GO
EXEC usp_undo_drop_table_test
GO

DROP PROCEDURE usp_drop_table_test
GO
DROP Procedure usp_undo_drop_table_test
GO

CREATE PROCEDURE usp_create_table_test
AS
BEGIN
	CREATE TABLE shepherder_vacation(
		vacation_id VARCHAR(20) PRIMARY KEY,
		vacation_date DATE,
		duration_in_days INT,
		shepherder_id VARCHAR(20),
		CONSTRAINT FK_shepherder_id_for_vacation FOREIGN KEY(shepherder_id) REFERENCES shepherder(shpid)
		ON DELETE CASCADE
		ON UPDATE CASCADE
	);
END
GO

EXEC usp_create_table_test
GO

DROP PROCEDURE usp_create_table_test
GO

CREATE PROCEDURE usp_undo_create_table_test
AS
BEGIN
	ALTER TABLE shepherder_vacation
		DROP CONSTRAINT FK_shepherder_id_for_vacation
	DROP TABLE shepherder_vacation
END
GO

EXEC usp_undo_create_table_test
GO

DROP PROCEDURE usp_undo_create_table_test
GO