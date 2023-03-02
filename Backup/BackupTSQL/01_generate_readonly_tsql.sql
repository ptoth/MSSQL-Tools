use master

DECLARE @db_name VARCHAR(150)
DECLARE @SQL_String NCHAR(1500)
DECLARE @back_path VARCHAR(150)

DECLARE CustList cursor for
SELECT name 
FROM master..sysdatabases 
WHERE name in 
(
	'MyDB', 'MyDB2'
)

OPEN CustList

FETCH NEXT FROM CustList 
INTO @db_name

WHILE @@FETCH_STATUS = 0
BEGIN

SET @SQL_String = '
	USE master; 
	GO 
	ALTER DATABASE [' + @db_name +'] 
	SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
	GO 
	ALTER DATABASE [' + @db_name +'] SET READ_ONLY; 
	GO 
	ALTER DATABASE [' + @db_name +'] SET MULTI_USER; 
	GO'
		
PRINT (RTRIM(@SQL_String))

FETCH NEXT FROM CustList 
	INTO @db_name
END

CLOSE CustList
DEALLOCATE CustList