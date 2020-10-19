SELECT
	'GRANT EXECUTE ON '+SPECIFIC_SCHEMA+'.'+SPECIFIC_NAME+' TO [Domain\Username]'
FROM DatabaseName.information_schema.routines
WHERE routine_type = 'PROCEDURE'
ORDER BY SPECIFIC_NAME