SELECT hobt_id, object_name(p.[object_id]), index_id 
FROM sys.partitions p 
WHERE hobt_id = 72057594060734464 