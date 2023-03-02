use master

DECLARE @db_name VARCHAR(150)
DECLARE @SQL_String NCHAR(1500)
DECLARE @back_path VARCHAR(150)

DECLARE CustList cursor for
SELECT name FROM master..sysdatabases WHERE name in 
(
	'MyDB', 'MyDB2'
)

SET @back_path =  '\\PATH\TO\REMOTE\BACKUP\SHARE\'

OPEN CustList

FETCH NEXT FROM CustList 
INTO @db_name

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @SQL_String = 'BACKUP DATABASE [' + @db_name +'] 
						TO  DISK = N''' + @back_path + @db_name + '_CO.bak'' 
						WITH NAME = N''' + @db_name + '-Full Database Backup'', 
						COPY_ONLY, 
						COMPRESSION, 
						stats  = 10, 
				'
PRINT (@SQL_String)
--		execute (@SQL_String)

FETCH NEXT FROM CustList 
	INTO @db_name
END
CLOSE CustList
DEALLOCATE CustList
