------------------------------Data file size---------------------------- 
IF EXISTS (SELECT *
           FROM   tempdb.sys.all_objects
           WHERE  NAME LIKE '%#dbsize%')
  DROP TABLE #dbsize

CREATE TABLE #dbsize
  (
     dbname         SYSNAME,
     dbstatus       VARCHAR(50),
     recovery_model VARCHAR(40) DEFAULT ('NA'),
     file_size_mb   DECIMAL(30, 2) DEFAULT (0),
     space_used_mb  DECIMAL(30, 2) DEFAULT (0),
     free_space_mb  DECIMAL(30, 2) DEFAULT (0)
  )

go

INSERT INTO #dbsize
            (dbname,
             dbstatus,
             recovery_model,
             file_size_mb,
             space_used_mb,
             free_space_mb)
EXEC Sp_msforeachdb
  'use [?]; 
  select DB_NAME() AS DbName, 
    CONVERT(varchar(20),DatabasePropertyEx(''?'',''Status'')) ,  
    CONVERT(varchar(20),DatabasePropertyEx(''?'',''Recovery'')),  
sum(size)/128.0 AS File_Size_MB, 
sum(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT))/128.0 as Space_Used_MB, 
SUM( size)/128.0 - sum(CAST(FILEPROPERTY(name,''SpaceUsed'') AS INT))/128.0 AS Free_Space_MB  
from sys.database_files  where type=0 group by type'

go

-------------------log size-------------------------------------- 
IF EXISTS (SELECT *
           FROM   tempdb.sys.all_objects
           WHERE  NAME LIKE '#logsize%')
  DROP TABLE #logsize

CREATE TABLE #logsize
  (
     dbname            SYSNAME,
     log_file_size_mb  DECIMAL(38, 2) DEFAULT (0),
     log_space_used_mb DECIMAL(30, 2) DEFAULT (0),
     log_free_space_mb DECIMAL(30, 2) DEFAULT (0)
  )

go

INSERT INTO #logsize
            (dbname,
             log_file_size_mb,
             log_space_used_mb,
             log_free_space_mb)
EXEC Sp_msforeachdb
  'use [?]; 
  select DB_NAME() AS DbName, 
sum(size)/128.0 AS Log_File_Size_MB, 
sum(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT))/128.0 as log_Space_Used_MB, 
SUM( size)/128.0 - sum(CAST(FILEPROPERTY(name,''SpaceUsed'') AS INT))/128.0 AS log_Free_Space_MB  
from sys.database_files  where type=1 group by type'

go

--------------------------------database free size 
IF EXISTS (SELECT *
           FROM   tempdb.sys.all_objects
           WHERE  NAME LIKE '%#dbfreesize%')
  DROP TABLE #dbfreesize

CREATE TABLE #dbfreesize
  (
     NAME          SYSNAME,
     database_size VARCHAR(50),
     freespace     VARCHAR(50) DEFAULT (0.00)
  )

INSERT INTO #dbfreesize
            (NAME,
             database_size,
             freespace)
EXEC Sp_msforeachdb
  'use [?];SELECT database_name = db_name() 
    ,database_size = ltrim(str((convert(DECIMAL(15, 2), dbsize) + convert(DECIMAL(15, 2), logsize)) * 8192 / 1048576, 15, 2) + ''MB'') 
    ,''unallocated space'' = ltrim(str(( 
                CASE  
                    WHEN dbsize >= reservedpages 
                        THEN (convert(DECIMAL(15, 2), dbsize) - convert(DECIMAL(15, 2), reservedpages)) * 8192 / 1048576 
                    ELSE 0 
                    END 
                ), 15, 2) + '' MB'') 
FROM ( 
    SELECT dbsize = sum(convert(BIGINT, CASE  
                    WHEN type = 0 
                        THEN size 
                    ELSE 0 
                    END)) 
        ,logsize = sum(convert(BIGINT, CASE  
                    WHEN type <> 0 
                        THEN size 
                    ELSE 0 
                    END)) 
    FROM sys.database_files 
) AS files 
,( 
    SELECT reservedpages = sum(a.total_pages) 
        ,usedpages = sum(a.used_pages) 
        ,pages = sum(CASE  
                WHEN it.internal_type IN ( 
                        202 
                        ,204 
                        ,211 
                        ,212 
                        ,213 
                        ,214 
                        ,215 
                        ,216 
                        ) 
                    THEN 0 
                WHEN a.type <> 1 
                    THEN a.used_pages 
                WHEN p.index_id < 2 
                    THEN a.data_pages 
                ELSE 0 
                END) 
    FROM sys.partitions p 
    INNER JOIN sys.allocation_units a 
        ON p.partition_id = a.container_id 
    LEFT JOIN sys.internal_tables it 
        ON p.object_id = it.object_id 
) AS partitions'

----------------------------------- 
IF EXISTS (SELECT *
           FROM   tempdb.sys.all_objects
           WHERE  NAME LIKE '%#alldbstate%')
  DROP TABLE #alldbstate

CREATE TABLE #alldbstate
  (
     dbname   SYSNAME,
     dbstatus VARCHAR(55),
     r_model  VARCHAR(30)
  )

--select * from sys.master_files 
INSERT INTO #alldbstate
            (dbname,
             dbstatus,
             r_model)
SELECT NAME,
       CONVERT(VARCHAR(20), Databasepropertyex(NAME, 'status')),
       recovery_model_desc
FROM   sys.databases

--select * from #dbsize 
INSERT INTO #dbsize
            (dbname,
             dbstatus,
             recovery_model)
SELECT dbname,
       dbstatus,
       r_model
FROM   #alldbstate
WHERE  dbstatus <> 'online'

INSERT INTO #logsize
            (dbname)
SELECT dbname
FROM   #alldbstate
WHERE  dbstatus <> 'online'

INSERT INTO #dbfreesize
            (NAME)
SELECT dbname
FROM   #alldbstate
WHERE  dbstatus <> 'online'

SELECT d.dbname,
       d.dbstatus,
       d.recovery_model,
       ( file_size_mb + log_file_size_mb ) AS DBsize,
       d.file_size_mb,
       d.space_used_mb,
       d.free_space_mb,
       l.log_file_size_mb,
       log_space_used_mb,
       l.log_free_space_mb,
       fs.freespace                        AS DB_Freespace
FROM   #dbsize d
       JOIN #logsize l
         ON d.dbname = l.dbname
       JOIN #dbfreesize fs
         ON d.dbname = fs.NAME
ORDER  BY dbname 