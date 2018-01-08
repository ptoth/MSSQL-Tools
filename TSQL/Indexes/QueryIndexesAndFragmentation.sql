SELECT DB_NAME(database_id) as 'Database',
	dbschemas.[name] as 'Schema',
    dbtables.[name] as 'Table',
    dbindexes.[name] as 'Index',
    indexstats.avg_fragmentation_in_percent,
	-- Default Rebuild SQL
	'ALTER INDEX ['+dbindexes.[name]+'] ON ['+dbschemas.[name]+'].['+dbtables.[name]+'] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)' AS DefaultRebuildSQL,
	-- Adaptive Index Defrag SQL
	'EXEC msdb.dbo.usp_AdaptiveIndexDefrag @sortInTempDB=1, @dbscope='''+DB_NAME(database_id)+''', '+'@tblName= '''+dbschemas.[name]+'.'+dbtables.[name]+'''; RAISERROR(''Indexes on '+dbschemas.[name]+'.'+dbtables.[name]+' rebuilded...'', 0, 42) WITH NOWAIT;' AS AdaptiveIndexDefragSQL
FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables
    ON dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas
    ON dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes
    ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
  AND dbindexes.[name] IS NOT NULL
  AND indexstats.avg_fragmentation_in_percent > 30
ORDER BY indexstats.avg_fragmentation_in_percent DESC

-- 2008:
SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName,
    ind.name AS IndexName,
    indexstats.index_type_desc AS IndexType,
    indexstats.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats
INNER JOIN sys.indexes ind
    ON ind.object_id = indexstats.object_id
    AND ind.index_id = indexstats.index_id 
WHERE ind.name IS NOT NULL
    AND indexstats.avg_fragmentation_in_percent > 30
ORDER BY indexstats.avg_fragmentation_in_percent DESC

-- 2000/2005
DECLARE @frag float;
DECLARE @dbname nvarchar(130);
DECLARE @dbid int;

-- Conditionally select tables and indexes from the sys.dm_db_index_physical_stats function
-- and convert object and index IDs to names.

-- change the name of the target database here
SET @dbname = N'Database'
-- change this value to adjust the threshold for fragmentation 
SET @frag = 10.0              

SELECT @dbid = dbid FROM sys.sysdatabases WHERE name = @dbname

SELECT
    --PS.object_id AS Objectid,
      S.name AS SchemaName,
      O.name AS ObjectName,
      I.name AS IndexName,
    --PS.index_id AS IndexId,
    --PS.partition_number AS PartitionNum,
    ROUND(PS.avg_fragmentation_in_percent, 2) AS Fragmentation,
      PS.record_count AS RecordCount
FROM sys.dm_db_index_physical_stats (@dbid, NULL, NULL , NULL, 'SAMPLED') PS
      JOIN sys.objects O ON PS.object_id = O.object_id
      JOIN sys.schemas S ON S.schema_id = O.schema_id
      JOIN sys.indexes I ON I.object_id = PS.object_id
            AND I.index_id = PS.index_id
WHERE PS.avg_fragmentation_in_percent > @frag AND PS.index_id > 0
ORDER BY Fragmentation DESC;