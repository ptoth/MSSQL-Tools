SELECT floor(a.avg_user_impact * a.avg_total_user_cost * a.user_seeks) as Weight,
      OBJECT_NAME(c.object_id, c.database_id) as 'Table',
      c.equality_columns,
      c.inequality_columns,
      c.included_columns,
      'CREATE INDEX TP_' + OBJECT_NAME(c.object_id, c.database_id) + '_' + replace(replace(replace(replace
      (ISNULL(equality_columns, '') + ISNULL(c.inequality_columns, ''), ', ', '_'),
      '[', ''), ']', ''), ' ', '') + ' ON [' + OBJECT_NAME(c.object_id, c.database_id) + '] (' + ISNULL(equality_columns, '') +
      CASE WHEN c.equality_columns IS NOT NULL
        AND c.inequality_columns IS NOT NULL THEN ', '
        ELSE '' END + ISNULL(c.inequality_columns, '') + ') ' + CASE WHEN included_columns IS NOT NULL THEN
        'INCLUDE (' + included_columns + ')' ELSE '' END + ' WITH (FILLFACTOR=70)' as SQL
    FROM sys.dm_db_missing_index_group_stats a
    JOIN sys.dm_db_missing_index_groups b
      ON a.group_handle = b.index_group_handle
    JOIN sys.dm_db_missing_index_details c
      ON b.index_handle = c.index_handle
    JOIN sys.objects d ON c.object_id = d.object_id
    WHERE c.database_id = db_id()
    ORDER BY -- DB_NAME(c.database_id), ISNULL(equality_columns, '') + ISNULL(c.inequality_columns, ''), 
      a.avg_user_impact * a.avg_total_user_cost * a.user_seeks DESC
