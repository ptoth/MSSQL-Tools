SELECT obj.name, 
	obj.object_id, 
	stat.name, 
	stat.stats_id, 
	last_updated, 
	modification_counter,
	rows
FROM sys.objects AS obj   
	INNER JOIN sys.stats AS stat ON stat.object_id = obj.object_id  
	CROSS APPLY sys.dm_db_stats_properties(stat.object_id, stat.stats_id) AS sp  
WHERE modification_counter > 1000
	AND obj.object_id > 100
ORDER BY last_updated