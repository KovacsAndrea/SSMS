USE [Clarkson's Farm Activities2]
GO
DROP PROCEDURE usp_add_column
DROP PROCEDURE usp_create_table
DROP PROCEDURE usp_modify_type_of_column
DROP PROCEDURE usp_remove_candidate_key
DROP PROCEDURE usp_remove_default_constraint
DROP PROCEDURE usp_remove_FK
DROP PROCEDURE usp_remove_PK
DROP PROCEDURE usp_undo_add_column
DROP PROCEDURE usp_undo_create_table
DROP PROCEDURE usp_undo_modify_type_of_column
DROP PROCEDURE usp_undo_remove_candidate_key
DROP PROCEDURE usp_undo_remove_default_constraint
DROP PROCEDURE usp_undo_remove_FK
DROP PROCEDURE usp_undo_remove_PK
GO
--/////////////////////////////////////////////////////////////////////////////
CREATE PROCEDURE usp_modify_type_of_column
AS
BEGIN
	ALTER TABLE plant
		ALTER COLUMN price SMALLINT
END
GO
EXEC usp_modify_type_of_column
GO

CREATE PROCEDURE usp_undo_modify_type_of_column
AS
BEGIN
	ALTER TABLE plant
		ALTER COLUMN price INT
END
GO
EXEC usp_undo_modify_type_of_column
GO





--/////////////////////////////////////////////////////////////////////////////
CREATE PROCEDURE usp_add_column
AS
BEGIN
	ALTER TABLE chicken_pen
		ADD color VARCHAR(50)
END
GO
EXEC usp_add_column
GO

CREATE PROCEDURE usp_undo_add_column
AS 
BEGIN
	ALTER TABLE chicken_pen
	DROP COLUMN color
END
GO
EXEC usp_undo_add_column
GO





--/////////////////////////////////////////////////////////////////////////////
CREATE PROCEDURE usp_remove_default_constraint
AS
BEGIN
	ALTER TABLE farm_shop
		DROP CONSTRAINT DF_shop_description
END
GO
EXEC usp_remove_default_constraint
GO

CREATE PROCEDURE usp_undo_remove_default_constraint
AS
BEGIN
	ALTER TABLE farm_shop
		ADD CONSTRAINT DF_shop_description DEFAULT ('TBA') FOR shop_description
END
GO
EXEC usp_undo_remove_default_constraint
GO





--/////////////////////////////////////////////////////////////////////////////
CREATE PROCEDURE usp_remove_PK
AS
BEGIN
	ALTER TABLE farm_shop
		DROP CONSTRAINT FK_shop_employee
	ALTER TABLE shop_employee
		DROP CONSTRAINT PK_shop_employee
END
GO
EXEC usp_remove_PK
GO

CREATE PROCEDURE usp_undo_remove_PK
AS
BEGIN
	ALTER TABLE shop_employee
		ADD CONSTRAINT PK_shop_employee PRIMARY KEY (empid)
	ALTER TABLE farm_shop
		ADD CONSTRAINT FK_shop_employee FOREIGN KEY (employee_id) REFERENCES shop_employee(empid)
END
GO
EXEC usp_undo_remove_PK
GO





--/////////////////////////////////////////////////////////////////////////////
CREATE PROCEDURE usp_remove_candidate_key
AS
BEGIN
	ALTER TABLE shop_employee
		DROP CONSTRAINT UQ_cnp
END
GO

CREATE PROCEDURE usp_undo_remove_candidate_key
AS
BEGIN
	ALTER TABLE shop_employee
		ADD CONSTRAINT UQ_cnp UNIQUE (CNP)
END
GO





--/////////////////////////////////////////////////////////////////////////////
CREATE PROCEDURE usp_remove_FK
AS 
BEGIN
	ALTER TABLE planting_harvesting
		DROP CONSTRAINT FK_plant_id
END
GO
EXEC usp_remove_FK
GO

CREATE PROCEDURE usp_undo_remove_FK
AS
BEGIN
	ALTER TABLE planting_harvesting
	ADD CONSTRAINT FK_plant_id FOREIGN KEY (plant_id) REFERENCES plant(plantid)
END
GO
EXEC usp_undo_remove_FK
GO





--/////////////////////////////////////////////////////////////////////////////
CREATE PROCEDURE usp_create_table
AS
BEGIN
	CREATE TABLE shepherder_vacation(
		vacation_id INT PRIMARY KEY,
		vacation_date DATE,
		duration_in_days INT,
		shepherder_id INT,
		CONSTRAINT FK_shepherder_id_for_vacation FOREIGN KEY(shepherder_id) REFERENCES shepherder(shpid)
		ON DELETE CASCADE
		ON UPDATE CASCADE
	);
END
GO

CREATE PROCEDURE usp_undo_create_table
AS
BEGIN
	ALTER TABLE shepherder_vacation
		DROP CONSTRAINT FK_shepherder_id_for_vacation
	DROP TABLE shepherder_vacation
END
GO

/*
DROP PROCEDURE usp_add_column
DROP PROCEDURE usp_create_table
DROP PROCEDURE usp_modify_type_of_column
DROP PROCEDURE usp_remove_candidate_key
DROP PROCEDURE usp_remove_default_constraint
DROP PROCEDURE usp_remove_FK
DROP PROCEDURE usp_remove_PK
DROP PROCEDURE usp_undo_add_column
DROP PROCEDURE usp_undo_create_table
DROP PROCEDURE usp_undo_modify_type_of_column
DROP PROCEDURE usp_undo_remove_candidate_key
DROP PROCEDURE usp_undo_remove_default_constraint
DROP PROCEDURE usp_undo_remove_FK
DROP PROCEDURE usp_undo_remove_PK
*/