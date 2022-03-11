SELECT
	'EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'''
	+ name
	+'''; DROP DATABASE ['
	+name
	+'] GO'
FROM sys.databases
WHERE database_id > 4
