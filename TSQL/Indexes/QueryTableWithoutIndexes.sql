SELECT 
    schemaname = OBJECT_SCHEMA_NAME(o.object_id),
    tablename = o.NAME
FROM sys.objects o
INNER JOIN sys.indexes i ON i.OBJECT_ID = o.OBJECT_ID
-- tables that are heaps without any nonclustered indexes
WHERE (
        o.type = 'U'
        AND o.OBJECT_ID NOT IN (
            SELECT OBJECT_ID
            FROM sys.indexes
            WHERE index_id > 0
            )
        )
        --  OR
        -- table that have a clustered index without any nonclustered indexes
        --(o.type='U' 
        --        AND o.OBJECT_ID NOT IN (
        --    SELECT OBJECT_ID 
        --        FROM sys.indexes 
        --        WHERE index_id>1))  