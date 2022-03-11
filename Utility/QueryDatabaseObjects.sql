DECLARE @ResultSet TABLE
(
  database_name VARCHAR(50),
  name VARCHAR(100),
  type_desc VARCHAR(100)
)

DECLARE @command varchar(1000) 
SELECT @command = 
	'IF ''?'' NOT IN(''master'', ''model'', ''tempdb'', ''msdb'')' + 
	'BEGIN ' +
	'USE [?] ' +
	'SELECT DB_NAME() AS CurrentDatabase, name, type_desc 
	FROM sys.objects 
	WHERE type IN 
	(
		''AF'' ,''C'' ,''D'',''F'' ,''FN'',''FS'',''FT'',''IF'',
		''P'' ,''PC'',''PG'',''PK'',''R'' ,''RF'',''SN'',''SO'',
		''U'' ,''V'' ,''EC'',''TA'',''TF'',''TR'',''TT'',''UQ'',
		''X'' ,''ET''
	) 
	UNION 
	SELECT DB_NAME() AS CurrentDatabase, 
		i.name, 
		i.type_desc
	FROM sys.indexes i
		INNER JOIN sys.tables t ON t.object_id = i.object_id
		INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
	WHERE i.name is not null
		AND t.type_desc = N''USER_TABLE'''+
	'END'
	
INSERT @ResultSet
EXEC sp_MSforeachdb @command 

SELECT *
FROM @ResultSet


/*
AF	: Aggregate function (CLR)
C	: CHECK constraint
D	: DEFAULT (constraint or stand-alone)
F	: FOREIGN KEY constraint
FN	: SQL scalar function
FS	: Assembly (CLR) scalar-function
FT	: Assembly (CLR) table-valued function
IF	: SQL inline table-valued function
IT	: Internal table
P	: SQL Stored Procedure
PC	: Assembly (CLR) stored-procedure
PG	: Plan guide
PK	: PRIMARY KEY constraint
R	: Rule (old-style, stand-alone)
RF	: Replication-filter-procedure
S	: System base table
SN	: Synonym
SO	: Sequence object
U	: Table (user-defined)
V	: View
EC	: Edge constraint

Applies to: SQL Server 2012 (11.x) and later.
SQ	: Service queue
TA	: Assembly (CLR) DML trigger
TF	: SQL table-valued-function
TR	: SQL DML trigger
TT	: Table type
UQ	: UNIQUE constraint
X	: Extended stored procedure

Applies to: SQL Server 2016 (13.x) and later, Azure SQL Database, Azure Synapse Analytics (SQL DW), Parallel Data Warehouse.
ET	: External Table
*/