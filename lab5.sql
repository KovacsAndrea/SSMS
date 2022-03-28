Use [Clarkson's Farm Activities2]
GO
DROP TABLE Tc
GO
DROP TABLE Ta
GO
DROP PROCEDURE usp_populate_Ta
GO
DROP PROCEDURE usp_GenerateRandomString2
GO

--Work on 3 tables of the form Ta(aid, a2, …), Tb(bid, b2, …), Tc(cid, aid, bid, …), where:

--aid, bid, cid, a2, b2 are integers;
--the primary keys are underlined;
--a2 is UNIQUE in Ta;
--aid and bid are foreign keys in Tc, referencing the primary keys in Ta and Tb, respectively.

--a. Write queries on Ta such that their execution plans contain the following operators:
--clustered index scan;
--clustered index seek;
--nonclustered index scan;
--nonclustered index seek;
--key lookup.




CREATE TABLE Ta (
	aid INT IDENTITY(1, 1) PRIMARY KEY,
	a2 INT UNIQUE,
	a3 VARCHAR(128)
)
GO



CREATE PROCEDURE usp_GenerateRandomString2(@random_string VARCHAR(MAX) OUTPUT)
AS
BEGIN
	DECLARE @Length INT, @Count INT, @PoolLength INT
	DECLARE @CharPool VARCHAR(MAX)

	SET @Length = 5
	SET @CharPool = 'QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm!@#$%^&*()~`_+=-'
	SET @PoolLength = LEN(@CharPool)
	SET @Count = 0
	SET @random_string = ''

	WHILE (@Count < @Length)
	BEGIN
		SET @random_string = @random_string + SUBSTRING(@Charpool, CONVERT(int, RAND() * @PoolLength) + 1, 4)
		SET @Count = @Count + 1
	END
END
GO


CREATE PROCEDURE usp_populate_Ta(@rows INT)
AS
BEGIN
	DECLARE @random_string VARCHAR(MAX)
	WHILE @rows > 0
	BEGIN
		EXEC usp_GenerateRandomString2 @random_string OUTPUT
		INSERT INTO Ta(a2, a3) VALUES
		(@rows *13, @random_string)
		SET @rows = @rows -1
	END
END
GO

EXEC usp_populate_Ta 500
GO




--a)
--clustered index seek
SELECT * FROM Ta WHERE aid = 339
GO
--clustered index scan
SELECT * FROM Ta
GO
--nonclustered index scan - not necesary because the UNIQUE on a2 prompts the server to create a nonclustered index on a2
--DROP INDEX IXa2 ON Ta
--GO
--CREATE NONCLUSTERED INDEX IXa2
--ON Ta(a2)

--nonclustered index seek
SELECT aid FROM Ta WHERE a2 = 223

--nonclustered index scan
SELECT a3 FROM Ta

--key loop
SELECT a3 FROM Ta WHERE a2 = 113




--B) Write a query on table Tb with a WHERE clause of the form WHERE b2 = value and analyze its execution plan. 
--Create a nonclustered index that can speed up the query. Examine the execution plan again.

DROP TABLE Tb
GO
CREATE TABLE Tb (
	bid INT IDENTITY(1, 1) Primary Key,
	b2 INT,
	b3 VARCHAR(128)
)
GO

DROP PROCEDURE usp_populate_Tb
GO
CREATE PROCEDURE usp_populate_Tb(@rows INT)
AS
BEGIN
	DECLARE @random_string VARCHAR(MAX)
	WHILE @rows > 0
	BEGIN
		EXEC usp_GenerateRandomString2 @random_string OUTPUT
		INSERT INTO Tb(b2, b3) VALUES
		(@rows *13, @random_string)
		SET @rows = @rows -1
	END
END
GO

EXEC usp_populate_Tb 500
SELECT * FROM Tb
GO

--estimated cost is 0.000707. In this case we have a clustered index scan, which
--is not very efficient. We want a NonClustered Index on b2 so we can get a NonClustered
--Index Seek, because seeks are more efficient than scans 
--With the nonclustered index the cost drops down to 0.0001581
SELECT bid FROM Tb WHERE b2 = 6435


CREATE NONCLUSTERED INDEX IXb2
ON Tb(b2)




--C) Create a view that joins at least 2 tables. Check whether existing indexes are helpful; 
--if not, reassess existing indexes / examine the cardinality of the tables.
CREATE TABLE Tc (
	cid INT IDENTITY(1,1) PRIMARY KEY,
	aid INT FOREIGN KEY REFERENCES Ta(aid),
	bid INT FOREIGN KEY REFERENCES Tb(bid),
)
GO

DROP PROCEDURE usp_populate_Tc
GO
CREATE PROCEDURE usp_populate_Tc(@rows INT)
AS
BEGIN
	DECLARE @faid INT, @fbid INT
	WHILE @rows > 0
	BEGIN
		SELECT TOP 1 @faid = aid FROM Ta ORDER BY NEWID()
		SELECT TOP 1 @fbid = bid FROM Tb ORDER BY NEWID()
		INSERT INTO Tc(aid, bid) VALUES
		(@faid, @fbid)
		SET @rows = @rows -1
	END
END
GO

EXEC usp_populate_Tc 100
SELECT * FROM Tb

DROP VIEW Tacb 
GO

CREATE VIEW Tacb AS
SELECT Ta.a2, Tb.b3 FROM Ta INNER JOIN Tc ON Ta.aid = Tc.aid INNER JOIN Tb ON Tc.bid = Tb.bid WHERE Tb.b2 = 5863
GO

SELECT * FROM Tacb

--SET SHOWPLAN_ALL ON
--SET SHOWPLAN_ALL OFF
--DROP INDEX IXb2 ON Tb

--0.0001581 with IXb2
--0.000418 without IXb2