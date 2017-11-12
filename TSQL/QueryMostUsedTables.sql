--get most used tables
SELECT 
	db_name(ius.database_id) AS DatabaseName,
	t.NAME AS TableName,
	SUM(ius.user_seeks + ius.user_scans + ius.user_lookups) AS NbrTimesAccessed
FROM sys.dm_db_index_usage_stats ius
    INNER JOIN sys.tables t ON t.OBJECT_ID = ius.object_id
WHERE database_id = DB_ID('MyDb')
GROUP BY database_id, t.name
ORDER BY SUM(ius.user_seeks + ius.user_scans + ius.user_lookups) DESC

