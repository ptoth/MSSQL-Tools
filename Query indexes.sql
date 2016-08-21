SELECT  OBJECT_SCHEMA_NAME(ind.object_id) AS SchemaName
    ,OBJECT_NAME(ind.object_id) AS ObjectName
    ,ind.name AS IndexName
    ,ind.is_primary_key AS IsPrimaryKey
    ,ind.is_unique AS IsUniqueIndex
    ,col.name AS ColumnName
    ,ic.is_included_column AS IsIncludedColumn
    ,ic.key_ordinal AS ColumnOrder
FROM sys.indexes ind
    INNER JOIN sys.index_columns ic
        ON ind.object_id = ic.object_id
           AND ind.index_id = ic.index_id
    INNER JOIN sys.columns col
        ON ic.object_id = col.object_id
           AND ic.column_id = col.column_id
    INNER JOIN sys.tables t
        ON ind.object_id = t.object_id
WHERE   t.is_ms_shipped = 0
ORDER BY OBJECT_SCHEMA_NAME(ind.object_id) --SchemaName
    ,OBJECT_NAME(ind.object_id) --ObjectName
    ,ind.is_primary_key DESC
    ,ind.is_unique DESC
    ,ind.name --IndexName
    ,ic.key_ordinal

/**/
SELECT OBJECT_NAME(ind.OBJECT_ID) AS TableName
    ,ind.name AS IndexName
    ,indexstats.index_type_desc AS IndexType
    ,indexstats.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats
    INNER JOIN sys.indexes ind
        ON ind.object_id = indexstats.object_id
        AND ind.index_id = indexstats.index_id
WHERE indexstats.avg_fragmentation_in_percent > 30
ORDER BY indexstats.avg_fragmentation_in_percent DESC
