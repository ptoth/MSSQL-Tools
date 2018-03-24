SELECT 
	'GRANT EXECUTE ON '+SPECIFIC_SCHEMA+'.'+SPECIFIC_NAME+' TO [TST\PalkoA1]'
FROM DatabaseName.information_schema.routines 
WHERE routine_type = 'PROCEDURE'
ORDER BY SPECIFIC_NAME