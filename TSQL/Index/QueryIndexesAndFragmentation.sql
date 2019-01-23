SELECT DB_NAME(database_id) as 'Database',
	dbschemas.[name] as 'Schema',
    dbtables.[name] as 'Table',
    dbindexes.[name] as 'Index',
    indexstats.avg_fragmentation_in_percent
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
  /* FIXME Index pages above 100 */
ORDER BY indexstats.avg_fragmentation_in_percent DESC