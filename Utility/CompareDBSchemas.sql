USE SSD_DBA
SELECT DB_NAME() AS CurrentDatabase, name, type_desc 
INTO #source_schema
FROM sys.objects 
	WHERE type IN 
	(
		'AF' ,'C' ,'D','F' ,'FN','FS','FT','IF',
		'P' ,'PC','PG','PK','R' ,'RF','SN','SO',
		'U' ,'V' ,'EC','TA','TF','TR','TT','UQ',
		'X' ,'ET'
	) 
	UNION 
	SELECT DB_NAME() AS CurrentDatabase, 
		i.name, 
		i.type_desc
	FROM sys.indexes i
		INNER JOIN sys.tables t ON t.object_id = i.object_id
		INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
	WHERE i.name is not null
		AND t.type_desc = N'USER_TABLE'

USE SSD_DBA_2
SELECT DB_NAME() AS CurrentDatabase, name, type_desc 
INTO #target_schema
FROM sys.objects 
	WHERE type IN 
	(
		'AF' ,'C' ,'D','F' ,'FN','FS','FT','IF',
		'P' ,'PC','PG','PK','R' ,'RF','SN','SO',
		'U' ,'V' ,'EC','TA','TF','TR','TT','UQ',
		'X' ,'ET'
	) 
	UNION 
	SELECT DB_NAME() AS CurrentDatabase, 
		i.name, 
		i.type_desc
	FROM sys.indexes i
		INNER JOIN sys.tables t ON t.object_id = i.object_id
		INNER JOIN sys.schemas s ON s.schema_id = t.schema_id
	WHERE i.name is not null
		AND t.type_desc = N'USER_TABLE'


--SELECT * FROM #source_schema
--SELECT * FROM #target_schema

SELECT 
	ISNULL(s.name, '-') as ObjectName_in_source, 
	ISNULL(t.name, '-') as ObjectName_in_target,
	ISNULL(s.type_desc, '-') as ObjectType_in_source,
	ISNULL(t.type_desc, '-') as ObjectType_in_target
FROM #source_schema s
FULL OUTER JOIN #target_schema t on s.name = t.name AND s.type_desc = t.type_desc


DROP TABLE #source_schema
DROP TABLE #target_schema
