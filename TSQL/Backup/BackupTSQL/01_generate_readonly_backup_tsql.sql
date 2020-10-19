use master

declare @db_name varchar(150)
declare @SQL_String nchar(1500)
declare @back_path varchar(150)

declare CustList cursor for
select name from master..sysdatabases where name in 
(
 'MyDB', 'MyDB2'
)

OPEN CustList

FETCH NEXT FROM CustList 
INTO @db_name

WHILE @@FETCH_STATUS = 0
BEGIN

set @SQL_String = '
USE master; 
GO 
ALTER DATABASE [' + @db_name +'] 
SET SINGLE_USER WITH ROLLBACK IMMEDIATE; 
GO 
ALTER DATABASE [' + @db_name +'] SET READ_ONLY; 
GO 
ALTER DATABASE [' + @db_name +'] SET MULTI_USER; 
GO'
		
print (RTRIM(@SQL_String))

FETCH NEXT FROM CustList 
	INTO @db_name
END

CLOSE CustList
DEALLOCATE CustList