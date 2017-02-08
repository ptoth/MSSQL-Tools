SELECT  dbschemas.[name] as 'Schema',
        dbtables.[name] as 'Table',
        dbindexes.[name] as 'Index',
        indexstats.avg_fragmentation_in_percent,
        'ALTER INDEX ['+dbindexes.[name]+'] ON ['+dbschemas.[name]+'].['+dbtables.[name]+'] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)'
FROM    sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS indexstats
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