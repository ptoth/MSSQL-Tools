use master

declare @db_name varchar(150)
declare @SQL_String nchar(1500)
declare @back_path varchar(150)

declare CustList cursor for
select name from master..sysdatabases where name in 
(
	'MyDB', 'MyDB2'
)

set @back_path =  '\\PATH\TO\REMOTE\BACKUP\SHARE\'

OPEN CustList

FETCH NEXT FROM CustList 
INTO @db_name

WHILE @@FETCH_STATUS = 0
BEGIN

	set @SQL_String = 'BACKUP DATABASE [' + @db_name +'] 
						TO  DISK = N''' + @back_path + @db_name + '_CO.bak'' 
						WITH NAME = N''' + @db_name + '-Full Database Backup'', 
						COPY_ONLY, 
						COMPRESSION, 
						stats  = 5, 
						BUFFERCOUNT = 40, 
						MAXTRANSFERSIZE = 4194304, 
						BLOCKSIZE = 65536 
				'
print (@SQL_String)
--		execute (@SQL_String)

FETCH NEXT FROM CustList 
	INTO @db_name
END
CLOSE CustList
DEALLOCATE CustList
