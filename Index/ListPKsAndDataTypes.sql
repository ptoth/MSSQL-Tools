SELECT 
    tab.[name] AS table_name,
    pk.[name] AS pk_name,
    col.[name] AS column_name, 
	ic.index_column_id AS column_id,
	col.user_type_id,
	t.name
FROM sys.tables tab
    INNER JOIN sys.indexes pk ON tab.object_id = pk.object_id AND pk.is_primary_key = 1
    INNER JOIN sys.index_columns ic ON ic.object_id = pk.object_id AND ic.index_id = pk.index_id
    INNER JOIN sys.columns col ON pk.object_id = col.object_id AND col.column_id = ic.column_id
	INNER JOIN sys.types t ON t.user_type_id = col.user_type_id
ORDER BY pk.[name],
    ic.index_column_id