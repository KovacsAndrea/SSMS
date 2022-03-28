USE [Clarkson's Farm Activities2]
GO

DROP PROCEDURE usp_update_Tables
GO

DROP PROCEDURE usp_update_Views
GO

DROP PROCEDURE usp_CreateInsertStatement
GO

DROP PROCEDURE usp_GenerateRandomString
GO

DROP PROCEDURE usp_run_my_test
GO

DROP FUNCTION column_table
GO

DROP PROCEDURE usp_final_columns_table
GO

DROP FUNCTION get_the_references
GO

DROP PROCEDURE usp_popolate_referenced_tables
GO

DELETE FROM Tests
GO



CREATE PROCEDURE usp_GenerateRandomString(@random_string VARCHAR(MAX) OUTPUT)
AS
BEGIN
	DECLARE @Length INT, @Count INT, @PoolLength INT
	DECLARE @CharPool VARCHAR(MAX)

	SET @Length = RAND() * 15 + 15
	SET @CharPool = 'QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm!@#$%^&*()~`_+=-'
	SET @PoolLength = LEN(@CharPool)
	SET @Count = 0
	SET @random_string = ''

	WHILE (@Count < @Length)
	BEGIN
		SET @random_string = @random_string + SUBSTRING(@Charpool, CONVERT(int, RAND() * @PoolLength) + 1, 1)
		SET @Count = @Count + 1
	END
END
GO



--a function that returns the names of the columns, the data type, and the constraints on each column.
--this works by doing an outer join between the columns table and the constraint column usage table.
--if we have multiple constraints however, that column will be added twice, so we need to fix that by 
--only keeping the most "important" constraint
--we don't have to bother with the not null constraint since none of our data will be null
--the check constraint: since i don't know how to find the parameters of the check constraints,
--we'll just drop the constraint from the table and then add it back once we're finished 
--if a varchar type has a unique constraint we'll put our hopes into our random string generator, since 
--it has quite a large pool of results (like between the length of this 'QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm!@#$%^&*()~`_+=-'
--to the power 15 and the power 30) 

CREATE FUNCTION dbo.column_table (@table_name VARCHAR(MAX))
RETURNS TABLE
AS
RETURN 
	SELECT _columns.COLUMN_NAME AS _column_name, _columns.DATA_TYPE as data_type, 
	       _keys.CONSTRAINT_NAME AS _constraint_name
	FROM (	SELECT * 
			FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE
			WHERE TABLE_NAME = @table_name ) AS _keys
	FULL OUTER JOIN
	     (	SELECT * 
			FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = @table_name) AS _columns
	ON _columns.COLUMN_NAME = _keys.COLUMN_NAME
GO



CREATE PROCEDURE usp_final_columns_table(@table_name VARCHAR(MAX))
AS
BEGIN
	SELECT *
	INTO column_types
	FROM column_table(@table_name)

	DELETE FROM column_types
	WHERE _constraint_name not like '%PK%' AND _constraint_name not like '%FK%' AND _column_name in (
		SELECT _column_name 
		FROM column_types
		GROUP BY _column_name
		HAVING COUNT(_column_name) >1)
END
GO


CREATE FUNCTION dbo.get_the_references (@table_name VARCHAR(MAX))
RETURNS @Ref TABLE(TableName VARCHAR(MAX), ColName VARCHAR(MAX))
AS
BEGIN
	INSERT INTO @Ref
	SELECT OBJECT_NAME(_tables.object_id) TableName,
	       COL_NAME(_fk_columns.referenced_object_id,_fk_columns.referenced_column_id) ColName
	FROM sys.tables AS _tables
		INNER JOIN sys.foreign_key_columns  AS _fk_columns 
	ON _fk_columns.referenced_object_id  = _tables.object_id
		INNER JOIN sys.tables AS _tables2 
	ON _tables2.object_id = _fk_columns.parent_object_id
	WHERE _tables2.name = 'testyyy'
	RETURN
END
GO



CREATE PROCEDURE usp_CreateInsertStatement (@table_name VARCHAR(MAX), @no_of_rows INT, @insert_statement VARCHAR(MAX) OUTPUT)
AS
BEGIN
	--checking if the table exists. if it doesn't we raise an error and return
	IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(@table_name) 
	               AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
		BEGIN
		RAISERROR('There no table "%s" in the database!',10,1, @table_name)
		RETURN
		END

	IF @no_of_rows <= 0
		BEGIN
		RAISERROR('Number of rows %d is invalid!',10,1, @no_of_rows)
		RETURN
		END
	--it there is a table start working on the insert statement
	SET @insert_statement = 'INSERT INTO ' + @table_name + ' VALUES'

	--we create a dummy table where each row is the type of column of the given table (i guess it's faster
	--this way since we don't go looking through the INFORMATION SCHEMA every time) we'll delete the table at the 
	--end of the procedure 
	
	--get our table
	EXEC usp_final_columns_table @table_name
 
	
	--i thought about this way too late
	DECLARE @quote VARCHAR(MAX)
	SET @quote = ''''


	DECLARE @our_id INT
	SET @our_id = 1


	--the no_of_rows parameter represents how many rows we will insert into the table. each row represents
	--one pass through the column_types tables. for each pass a new cursor will be declared and then deallocated
	--in order to parse the column types (??? is there a way to do with the cursor something like "if there are no 
	--more rows fetch first again?" CURSOR_STATUS just shows if the cursor is opened or not 
	--DECLARE @status INT = (SELECT CURSOR_STATUS('global', 'column_cursor'))
	--PRINT CAST (@status as VARCHAR(MAX))
	
	
	WHILE @no_of_rows > 0
	BEGIN
		--it means we are adding a new row, so let's take care of the synthax
		SET @insert_statement = @insert_statement + '('

		--cursor stuff
		DECLARE column_cursor CURSOR FOR
		SELECT data_type, _column_name, _constraint_name
		FROM column_types
		OPEN column_cursor

		DECLARE @data_type VARCHAR(MAX), @_column_name VARCHAR(MAX), @_constraint_name VARCHAR(MAX)
		FETCH FROM column_cursor
		INTO @data_type, @_column_name, @_constraint_name


			WHILE @@FETCH_STATUS = 0
			BEGIN
				DECLARE @current_data_type VARCHAR(MAX) = CAST(@data_type AS VARCHAR(MAX))
				--"numerele naturale"
				IF @current_data_type = 'int' OR 
				   @current_data_type = 'bigint' OR
				   @current_data_type = 'smallint' OR
				   @current_data_type = 'decimal' OR
				   @current_data_type = 'numeric' 
					BEGIN 
						IF @_constraint_name LIKE '%PK%' OR @_constraint_name LIKE '%FK%'
						BEGIN
							SET @insert_statement = @insert_statement + CAST(@our_id AS VARCHAR(MAX))
						END
						ELSE
						BEGIN
							SET @insert_statement = @insert_statement + 
							CAST( ROUND(-10000 + 20000 * RAND(), 0) AS VARCHAR(MAX))
						END
					END
			

				--"numerele reale"
				ELSE
				IF @current_data_type = 'money' OR
				   @current_data_type = 'smallmoney' OR
				   @current_data_type = 'float' OR
				   @current_data_type = 'real' 
				   BEGIN 
						SET @insert_statement = @insert_statement + 
						CAST( 100 * Rand() AS VARCHAR(MAX))
				   END

				--"data"
				ELSE
				IF @current_data_type = 'date' 
					BEGIN
						--we will generate a random number of days, then add it to the current date. let's say we'll generate 
						--values from 100 years back and 100 years from now (date holds values from 0001-01-01  to	9999-12-31
						--so ww won't get overflow). 365 days in a year, so we'll need to generate values from -36500 to 36500
						--SELECT ROUND ( -36500 + 73000 * RAND(), 0). Now the adding part. DATEADD (datepart , number , date )  
						--datepart will be day, number will be the RAND number and the date will be the current date which we will
						--get with GETDATE(). GETDATE needs to be converted to date to get rid of the hour minutes and seconds
						--SELECT DATEADD(dd, ROUND ( -36500 + 73000 * RAND(), 0), CONVERT(DATE, GETDATE()))
						DECLARE @Random_date VARCHAR(MAX)
						SET @Random_date = DATEADD(dd, ROUND ( -36500 + 73000 * RAND(), 0), CONVERT(DATE, GETDATE()))
						SET @insert_statement = @insert_statement + @quote + @Random_date + @quote
					END

				--"data si timp"
				ELSE
				IF @current_data_type = 'datetime' OR
				   @current_data_type = 'smalldatetime' OR
				   @current_data_type = 'datetimeoffset' OR
				   @current_data_type = 'datetime2' 
					BEGIN
						--smalldatetime goes from 1900-01-01 to 2079-06-06. So we will only generate values from 50 years back and
						--50 years from now, just to be safe. That means SELECT ROUND(-365*50 + 365+100 * RAND(), 0)
						--Now the seconds: There are 86400000 milliseconds in a day. So we will generate a random number from 0 to 86400000
						--and add it to the current date.
						--SELECT ROUND ( -18250 + 36500*RAND(), 0)
						--SELECT ROUND ( 86400*RAND(), 0)
						DECLARE @Random_date_time VARCHAR(MAX)
						SET @Random_date_time = DATEADD(dd, ROUND ( -18250 + 36500*RAND(), 0), DATEADD(ms, ROUND (86400000 * RAND(), 0), GETDATE()))
						SET @insert_statement = @insert_statement + @quote + @Random_date_time + @quote
					END

				--"timp"
				ELSE
				IF @current_data_type = 'time' 
					BEGIN 
						--add a random number between 0 and 86400000 to the current date casted as time
						DECLARE @Random_time VARCHAR(MAX)
						SET @Random_time = DATEADD(ms, ROUND(86400000 * RAND(), 0), CONVERT(TIME,  GETDATE()))
						SET @insert_statement = @insert_statement + @quote + @Random_time + @quote
					END

				--"text"
				ELSE
				IF @current_data_type = 'varchar' OR
				   @current_data_type = 'char' OR
				   @current_data_type = 'text' OR
				   @current_data_type = 'nvarchar' OR
				   @current_data_type = 'nchar' OR
				   @current_data_type = 'ntext' 
					BEGIN 
						DECLARE @random_string VARCHAR(MAX)
						EXEC usp_GenerateRandomString @random_string OUTPUT
						
						SET @insert_statement = @insert_statement + @quote + @random_string + @quote
					END

				ELSE
					SET @insert_statement = @insert_statement + 'NULL'
				

				--we have added one element for a column in one insert statament, which means we need a comma
				--We'll add only commas for the moment then delete the last 
				SET @insert_statement = @insert_statement + ','
				FETCH NEXT FROM column_cursor
				INTO @data_type, @_column_name, @_constraint_name
			END

		--close the cursor
		CLOSE column_cursor
		DEALLOCATE column_cursor

		--synthax time, we have completed one row.        
		SET @insert_statement = SUBSTRING(@insert_statement, 0, LEN(@insert_statement))
		SET @insert_statement = @insert_statement + '),'
		SET @our_id = @our_id + 1
		SET @no_of_rows = @no_of_rows -1
	END
    
	--statement completed
	SET @insert_statement = SUBSTRING(@insert_statement, 0, LEN(@insert_statement))
	DROP TABLE column_types
END
GO



DROP PROCEDURE  usp_drop_table_constraints 
GO
CREATE PROCEDURE usp_drop_table_constraints 
AS
BEGIN
		ALTER TABLE testyyy
		DROP CONSTRAINT PK_testyyy
		ALTER TABLE testyyy
		DROP CONSTRAINT FK_testyyy
		ALTER TABLE test_kid
		DROP CONSTRAINT PK_test_kid
		DELETE FROM testyyy
		DELETE FROM test_kid
		ALTER TABLE test_kid
		ADD CONSTRAINT PK_test_kid PRIMARY KEY(_int_fk)
		ALTER TABLE testyyy
		ADD CONSTRAINT FK_testyyy FOREIGN KEY (_int3) REFERENCES test_kid(_int_fk)
		ALTER TABLE testyyy
		ADD CONSTRAINT PK_testyyy PRIMARY KEY(_int, _int2)
END
GO




DROP PROCEDURE add_constraints
GO
CREATE PROCEDURE add_constraints
AS
BEGIN
		ALTER TABLE test_kid
		ADD CONSTRAINT PK_test_kid PRIMARY KEY(_int_fk)
		ALTER TABLE testyyy
		ADD CONSTRAINT PK_testyyy PRIMARY KEY(_int, _int2)
		ALTER TABLE testyyy
		ADD CONSTRAINT FK_testyyy FOREIGN KEY (_int3) REFERENCES test_kid(_int_fk)

END
GO





CREATE PROCEDURE usp_popolate_referenced_tables(@table_name VARCHAR(MAX), @no_of_rows INT)
AS
BEGIN
		DECLARE table_cursor CURSOR FOR
		SELECT TableName 
		FROM get_the_references(@table_name)
		OPEN table_cursor

		DECLARE @TableName VARCHAR(MAX)
		FETCH FROM table_cursor
		INTO @TableName
		EXEC usp_drop_table_constraints
		WHILE @@FETCH_STATUS = 0
			BEGIN
			PRINT @TableName
				DECLARE @statement VARCHAR (MAX)
				SET @statement = ''
				EXEC usp_CreateInsertStatement @TableName, @no_of_rows, @insert_statement = @statement OUTPUT
				
				EXEC (@statement)
				
				--EXEC ('SELECT * FROM ' + @TableName)
				FETCH NEXT FROM table_cursor
				INTO @TableName
			END
		SET ANSI_WARNINGS ON
		CLOSE table_cursor
		DEALLOCATE table_cursor
END
GO



DROP TABLE testyyy
GO

DROP TABLE test_kid
GO

CREATE TABLE test_kid(
	_int_fk INT,
	CONSTRAINT PK_test_kid PRIMARY KEY(_int_fk)
)
GO

CREATE TABLE testyyy(
	_decimal DECIMAL,
	_numeric NUMERIC,
	_money MONEY,
	_small_money SMALLMONEY,
	_float FLOAT,
	_real REAL,
	_int INT, 
	_int2 INT,
	_int3 INT,
	CONSTRAINT FK_testyyy FOREIGN KEY (_int3) REFERENCES test_kid(_int_fk),
	CONSTRAINT PK_testyyy PRIMARY KEY(_int, _int2),
	--FOREIGN KEY (_int) REFERENCES test_kid (_int_fk) ON DELETE CASCADE,
	_big_int BIGINT,
	_small_int SMALLINT,
	_date DATE,
	_date_time DATETIME,
	_small_date_time SMALLDATETIME,
	_date_time_offset DATETIMEOFFSET,
	_date_time_2 DATETIME2,
	_time TIME,
	_varchar VARCHAR(MAX),
	_varchar15 VARCHAR(15),
	_varchar2 VARCHAR(2),
	_char CHAR,
	_char5 CHAR(10),
	_text TEXT,
	_nvarchar NVARCHAR(MAX),
	_nvarchar15 NVARCHAR(15),
	_nvarchar2 NVARCHAR(2),
	_nchar NCHAR,
	_nchar5 NCHAR(10),
	_ntext NTEXT,
	_binary BINARY
)
GO


SELECT *
FROM get_the_references('testyyy')
GO


CREATE PROCEDURE usp_update_Tables
AS 
BEGIN
	DBCC CHECKIDENT ( '[dbo].[Tables]', RESEED, 0 )
	DELETE FROM Tables
	INSERT INTO Tables (Name) VALUES ('testyyy'), ('test_kid')
	
	--INSERT INTO Tables (Name)
	--	SELECT name
	--	FROM SYSOBJECTS
	--	WHERE xtype = 'U' AND name NOT LIKE '%table%' 
	--				  AND name NOT LIKE '%Table%' 
	--				  AND name NOT LIKE '%View%'
	--				  AND name NOT LIKE '%Test_%'
	--				  AND name NOT LIKE '%diagram%'
	
END 
GO
EXEC usp_update_Tables
GO
EXEC usp_update_Tables
GO


CREATE PROCEDURE usp_update_Views
AS
BEGIN
	DELETE FROM Views
	DBCC CHECKIDENT ( '[dbo].[Views]', RESEED, 0 )
	INSERT INTO Views (Name)
		SELECT name
		FROM SYSOBJECTS
		WHERE xtype = 'V' AND name NOT LIKE '%table%' 
				AND name NOT LIKE '%Table%' 
				AND name NOT LIKE '%View%'
				AND name NOT LIKE '%Test%'
END
GO
EXEC usp_update_Views
GO
EXEC usp_update_Views
GO
--SELECT * FROM Views
--SELECT * FROM Tables

--DELETE FROM TestRuns

DELETE FROM Tests 
DBCC CHECKIDENT ( '[dbo].[Tests]', RESEED, 0 )
INSERT INTO Tests VALUES
('table test 200'),
('view 1'),
('view 2'),
('view 3'),
('table test 500'),
('table test 1000');
SELECT * FROM Tests

DELETE FROM TestTables
INSERT INTO TestTables VALUES
(1, 1, 200, 0),
(5, 1, 500, 0),
(6, 1, 1000, 0)
GO

--DELETE FROM TestViews
--INSERT INTO TestViews VALUES
--(2,4), --NumberOfShepherdersOnEachParcel
--(3,2), --PHProjectsLengthinDays
--(4,3)  --TotalQuantityOfEachMaterial
--GO




CREATE PROCEDURE usp_run_my_test(@table_id INT, @test_id INT)
AS
BEGIN
	DECLARE @no_of_rows INT
	SET @no_of_rows = 
		(SELECT T.NoOfRows
		FROM TestTables T
		WHERE T.TestID = @test_id)
	PRINT @no_of_rows
	DECLARE @table_name VARCHAR(MAX)
	SET @table_name =
		(SELECT T.Name
		FROM Tables T
		WHERE T.TableID = @table_id)

	EXEC usp_popolate_referenced_tables @table_name, @no_of_rows
	DECLARE @statement VARCHAR (MAX)
	SET @statement = ''

	EXEC usp_CreateInsertStatement @table_name, @no_of_rows, @insert_statement = @statement OUTPUT
	PRINT @statement
	SET ANSI_WARNINGS  OFF
	DECLARE @date1 DATETIME = SYSDATETIME()
	EXEC (@statement)
	DECLARE @date2 DATETIME = SYSDATETIME()
	SET ANSI_WARNINGS  ON
	EXEC usp_drop_table_constraints
	DECLARE @date3 DATETIME = SYSDATETIME()

	DECLARE @description VARCHAR(MAX) =
	(SELECT T.Name
	FROM Tests T
	WHERE T.TestID = @test_id)
	INSERT INTO TestRuns VALUES ( @description, @date1, @date2)
	DECLARE @last INT =
	(SELECT TOP 1 TestRunID FROM TestRuns ORDER BY TestRunID DESC)
	INSERT INTO TestRunTables VALUES (@last, @table_id, @date1, @date2)
END
GO

DROP PROCEDURE usp_run_my_view_test
GO

CREATE PROCEDURE usp_run_my_view_test (@view_id INT, @test_id INT)
AS
BEGIN
	DECLARE @view_name VARCHAR(MAX) =
		(SELECT V.Name
		FROM Views V
		WHERE V.ViewID = 4)
	DECLARE @date1 DATETIME = SYSDATETIME()
	EXEC ('SELECT * FROM [' + @view_name +']')
	DECLARE @date2 DATETIME = SYSDATETIME()

	DECLARE @description VARCHAR(MAX) =
		(SELECT T.Name
		FROM Tests T
		WHERE T.TestID = @test_id)
	INSERT INTO TestRuns VALUES ( @description, @date1, @date2)
	DECLARE @last INT =
	(SELECT TOP 1 TestRunID FROM TestRuns ORDER BY TestRunID DESC)
	INSERT INTO TestRunViews VALUES (@last, @view_id, @date1, @date2)
END
GO



DROP PROCEDURE usp_all_tests
GO

CREATE PROCEDURE usp_all_tests(@name VARCHAR(MAX), @test_id INT)
AS
BEGIN
	DECLARE @obj_type VARCHAR(3) =
		(SELECT XTYPE
		FROM SYSOBJECTS
		WHERE NAME = @name)

	IF @obj_type = 'U'
	BEGIN
		DECLARE @id INT =
			(SELECT T.TableID
			FROM Tables T
			WHERE T.Name = @name)
		EXEC usp_run_my_test @id, @test_id
	END
	IF @obj_type = 'V'
	BEGIN
		DECLARE @id2 INT =
			(SELECT V.ViewID
			FROM Views V
			WHERE V.Name = 'NumberOfShepherdersOnEachParcel')
		EXEC usp_run_my_view_test 4, 2
	END
	ELSE
	RETURN
END
GO

EXEC usp_all_tests 'testyyy', 1
GO

EXEC usp_all_tests 'testyyy', 5
GO

EXEC usp_all_tests 'NumberOfShepherdersOnEachParcel', 2
GO

EXEC usp_all_tests 'PHProjectsLengthinDays', 3
GO

EXEC usp_all_tests 'TotalQuantityOfEachMaterial', 3
GO


SELECT * FROM TestRuns
SELECT * FROM TestRunTables
SELECT * FROM TestRunViews

DROP PROCEDURE usp_show_the_madness
GO
CREATE PROCEDURE usp_show_the_madness(@table_id INT, @test_id INT)
AS
BEGIN
	DECLARE @no_of_rows INT
	SET @no_of_rows = 
		(SELECT T.NoOfRows
		FROM TestTables T
		WHERE T.TestID = @test_id)
	PRINT @no_of_rows
	DECLARE @table_name VARCHAR(MAX)
	SET @table_name =
		(SELECT T.Name
		FROM Tables T
		WHERE T.TableID = @table_id)

	EXEC usp_popolate_referenced_tables @table_name, @no_of_rows
	DECLARE @statement VARCHAR (MAX)
	SET @statement = ''

	EXEC usp_CreateInsertStatement @table_name, @no_of_rows, @insert_statement = @statement OUTPUT
	PRINT @statement
	SET ANSI_WARNINGS  OFF
	EXEC (@statement)
	SET ANSI_WARNINGS  ON
	
	EXEC ('SELECT * FROM ' + @table_name)
	EXEC usp_drop_table_constraints
END
GO

EXEC usp_show_the_madness 1, 1