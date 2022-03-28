USE [Clarkson's Farm Activities2]
GO

DROP TABLE stored_procedure_table
GO
DROP TABLE current_version_table
GO
DROP PROCEDURE version_mechanism
GO
CREATE TABLE stored_procedure_table(
	db_version INT NOT NULL,
	CONSTRAINT UQ_db_version UNIQUE(db_version),
	CONSTRAINT PK_db_version PRIMARY KEY(db_version),
	stored_procedure VARCHAR(MAX), 
	reverse_strored_procedure VARCHAR(MAX)
);
GO

CREATE TABLE current_version_table(
	current_db_version INT NOT NULL
);
GO

INSERT INTO stored_procedure_table(db_version, stored_procedure, reverse_strored_procedure) VALUES
(1,'usp_modify_type_of_column','usp_undo_modify_type_of_column'),
(2,'usp_add_column', 'usp_undo_add_column'),
(3,'usp_remove_default_constraint','usp_undo_remove_default_constraint'),
(4,'usp_remove_PK','usp_undo_remove_PK'),
(5,'usp_remove_candidate_key', 'usp_undo_remove_candidate_key'),
(6,'usp_remove_FK','usp_undo_remove_FK'),
(7,'usp_create_table', 'usp_undo_create_table');
GO

INSERT INTO current_version_table(current_db_version) VALUES (0)
GO

--SELECT *
--FROM stored_procedure_table
--GO

--SELECT *
--FROM current_version_table
--GO

--SELECT *
--FROM current_version_table CV, stored_procedure_table SP
--GO

----CREATE PROCEDURE version_mechanism

--DECLARE @str VARCHAR(MAX)
--SET @str = (SELECT reverse_strored_procedure from stored_procedure_table where db_version = 4)
--PRINT @str
--DECLARE @strr VARCHAR(MAX)
--SET @strr = 'usp_' + SUBSTRING(@str,10, len(@str) - 9)
--PRINT @strr
--GO



CREATE PROCEDURE version_mechanism (@input_version INT)
AS
	--GET THE CURRENT VERSION OF THE TABLE
	DECLARE @current_version INT
	SET @current_version = (SELECT current_db_version FROM current_version_table)
	BEGIN

	--CHECK IF THE VERSION IS VALID, IF IT IS SMALLER THAN 0 OR GREATER THAN POSSIBLE 
	IF @input_version < 0
		BEGIN
		RAISERROR('Version can not be a negative number',10,1)
		RETURN
		END
	IF @input_version > (SELECT MAX(db_version) FROM stored_procedure_table)
		BEGIN
		RAISERROR('Version is too great',10,1)
		RETURN
		END
	ELSE IF @input_version = @current_version
		BEGIN
		PRINT 'You are already running on version ' + CAST(@input_version AS VARCHAR(MAX))
		RETURN
		END
	
	--INPUT VERSION IS SMALLER THAN THE CURRENT VERSION
	ELSE IF @input_version < @current_version  
		--say input version is 1, curent version is 4, 
		BEGIN
			--DECLARE A CURSOR TO GO OVER THE VERSIONS
			DECLARE version_cursor SCROLL CURSOR FOR
			SELECT db_version, reverse_strored_procedure
			FROM stored_procedure_table
			WHERE db_version > @input_version AND db_version <= @current_version
			ORDER BY db_version
			--Say input version is 1, curent version is 4. The ids of the procedures selected by this statement
			--will be in this order 2, 3, 4. Since we need to decrease versions, we need to execute the undo 
			--stored procedure of each stored procedure 

			--OPEN THE CURSOR/ EXECUTE THE SELECT STATEMENT
			OPEN version_cursor

			--PUT THE CURSOR AT THE LAST ROW WHICH WILL CORRESPOND TO THE CURRENT VERSION
			--because the undo stored procedures are in the order 2,3,4 we need to do FETCH LAST
			--alternative versioun would have been ORDER BY db_version DESC and FETCH FIRST 
			DECLARE @iterate_versions INT, @undo_procedure_name VARCHAR(MAX)
			FETCH LAST FROM version_cursor
			INTO @iterate_versions, @undo_procedure_name

			--TAKE ALL THE VERSIONS IN REVERSE ORDER OF THE VERSION FROM THE CURRENT VERSION
			--alternative version: FETCH NEXT
			WHILE @iterate_versions > @input_version AND @@FETCH_STATUS = 0
			BEGIN
				EXEC @undo_procedure_name
				UPDATE current_version_table SET current_db_version = current_db_version - 1
				FETCH PRIOR FROM  version_cursor
				INTO @iterate_versions, @undo_procedure_name
			END
			CLOSE version_cursor
			DEALLOCATE version_cursor
			PRINT 'Changed from version ' + CAST(@current_version AS VARCHAR(MAX)) +
					' to lower version ' + CAST(@input_version AS VARCHAR(MAX))
		END
	ELSE
		BEGIN
			DECLARE version_cursor CURSOR FOR
			SELECT db_version, stored_procedure
			FROM stored_procedure_table
			WHERE db_version > @current_version AND db_version <= @input_version
			ORDER BY db_version

			--DECLARE @iterate_version INT, @redo_procedure_name VARCHAR(MAX)
			DECLARE @procedure_name VARCHAR(MAX)
			OPEN version_cursor
			FETCH NEXT FROM version_cursor
			INTO @iterate_versions, @procedure_name

			WHILE @iterate_versions <= @input_version AND @@FETCH_STATUS = 0
			BEGIN
				EXEC @procedure_name 
				UPDATE current_version_table SET current_db_version = current_db_version + 1

				FETCH FROM version_cursor
				INTO @iterate_versions, @procedure_name
			END
			CLOSE version_cursor
			DEALLOCATE version_cursor
			PRINT 'Changed from version ' + CAST(@current_version AS VARCHAR(MAX)) +
				' to higher version ' + CAST(@input_version AS VARCHAR(MAX))
		END
END
GO

DECLARE @input_version INT
SET @input_version = 0
EXEC version_mechanism @input_version = -1
GO
EXEC version_mechanism @input_version = 8
GO
EXEC version_mechanism @input_version = 0
GO

SELECT* 
FROM current_version_table

SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'plant'
AND COLUMN_NAME = 'price';
GO

SELECT * 
FROM chicken_pen
GO


EXEC version_mechanism @input_version = 2
GO

SELECT *
FROM current_version_table

SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'plant'
AND COLUMN_NAME = 'price';
GO

SELECT * 
FROM chicken_pen
GO


EXEC version_mechanism @input_version = 1
GO

SELECT *
FROM current_version_table

SELECT * 
FROM chicken_pen
GO

EXEC version_mechanism @input_version = 0
GO

SELECT *
FROM current_version_table

SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'plant'
AND COLUMN_NAME = 'price';

EXEC version_mechanism @input_version = 4
GO
SELECT *
FROM current_version_table
EXEC version_mechanism @input_version = 0
GO
SELECT *
FROM current_version_table

EXEC version_mechanism @input_version = 6
GO
SELECT *
FROM current_version_table
EXEC version_mechanism @input_version = 7
GO
SELECT *
FROM current_version_table
EXEC version_mechanism @input_version = 0
GO
SELECT *
FROM current_version_table