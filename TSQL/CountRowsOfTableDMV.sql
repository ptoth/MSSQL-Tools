SELECT @count = SUM(p.rows)
FROM sys.partitions AS p
    INNER JOIN sys.tables AS t
        ON p.[object_id] = t.[object_id]
    INNER JOIN sys.schemas AS s
        ON t.[schema_id] = s.[schema_id]
WHERE p.index_id IN (0,1) -- heap or clustered index
    AND t.name = N'tablename'
    AND s.name = N'dbo';
