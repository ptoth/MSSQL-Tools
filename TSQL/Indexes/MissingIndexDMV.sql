SELECT
    sys.objects.NAME AS TableName,
    ( avg_total_user_cost * avg_user_impact ) * ( user_seeks + user_scans ) AS Impact,
    'CREATE NONCLUSTERED INDEX INDX_IndexName ON ' + sys.objects.NAME COLLATE database_default + ' ( ' + Isnull(mid.equality_columns, '') +
    CASE
        WHEN mid.inequality_columns IS NULL THEN ''
        ELSE
            CASE
                WHEN mid.equality_columns IS NULL THEN ''
                ELSE ','
            END +  mid.inequality_columns
        END + ' ) ' +
    CASE
        WHEN
        mid.included_columns IS NULL THEN ''
        ELSE 'INCLUDE (' + mid.included_columns + ')' 
        END + ';' 
    AS CreateIndexStatement,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM sys.dm_db_missing_index_group_stats AS migs
    INNER JOIN sys.dm_db_missing_index_groups AS mig
        ON migs.group_handle = mig.index_group_handle
    INNER JOIN sys.dm_db_missing_index_details AS mid
        ON mig.index_handle = mid.index_handle
        AND mid.database_id = Db_id()
    INNER JOIN sys.objects WITH (NOLOCK)
        ON mid.object_id = sys.objects.object_id
WHERE ( migs.group_handle IN 
        (SELECT TOP (500) group_handle
        FROM sys.dm_db_missing_index_group_stats WITH (NOLOCK)
        ORDER BY ( avg_total_user_cost * avg_user_impact) * ( user_seeks + user_scans ) DESC
        ) 
      )
AND Objectproperty(sys.objects.object_id, 'isusertable') = 1
ORDER BY 2 DESC, 3 DESC