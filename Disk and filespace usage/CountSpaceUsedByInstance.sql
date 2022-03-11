USE master
CREATE table #t (Database_name varchar(200),Logical_Name varchar(200),Full_Path varchar(200),Space_Reserved real , Space_Used real)
 
DECLARE @first_value varchar(150)
DECLARE @SQL_String nchar(1500)
DECLARE CustList cursor for
SELECT name FROM master..sysdatabases WHERE dbid > 4 AND (status & 512) <> 512
 
OPEN CustList
 
FETCH NEXT FROM CustList 
INTO @first_value
 
WHILE @@FETCH_STATUS = 0
BEGIN
      set @SQL_String = 'USE [' + @first_value +']; 
                        INSERT INTO #t (Database_name,Logical_Name,Full_Path,Space_Reserved,Space_Used)
                        (
                            SELECT Database_name = '''+ @first_value +''', name, Physical_Name, size/128.0 as ''Space Reserved (MB)'', 
                            CAST(FILEPROPERTY(name, ''SpaceUsed'')AS int)/128.0 as ''Space_Used MB''
                            FROM sys.database_files
                        );'
      print (@SQL_String)
      execute (@SQL_String)  
      
      FETCH NEXT FROM CustList 
      INTO @first_value
END

INSERT INTO #t (Database_name, Logical_Name,Full_Path,Space_Reserved,Space_Used)
    (
        SELECT Database_name = 'DB', Logical_Name='z_Sum',Full_Path='=',sum(Space_Reserved),sum(Space_Used) 
        FROM #t
    )

SELECT Database_name,Logical_Name,Full_Path,round(Space_Reserved,2) 'Space_Reserved (MB)',round(Space_Used,2) 'Space_Used (MB)' , round(Space_Reserved - Space_Used,2) 'Unallocated (MB)'
FROM #t  
ORDER BY 6 DESC

CLOSE CustList
DEALLOCATE CustList
DROP TABLE #t