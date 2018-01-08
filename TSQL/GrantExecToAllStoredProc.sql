SELECT 
	'GRANT EXECUTE ON '+SPECIFIC_SCHEMA+'.'+SPECIFIC_NAME+' TO [TST\PalkoA1]'
  from DatabaseName.information_schema.routines 
 where routine_type = 'PROCEDURE'
 ORDER BY SPECIFIC_NAME