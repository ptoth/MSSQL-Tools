SELECT SESSION_ID as SPID,
	command,
	STATUS,
	a.text AS Query,
	start_time,
	percent_complete,
	DATEADD(second,estimated_completion_time/1000, GETDATE()) as estimated_completion_time,
	total_elapsed_time
FROM sys.dm_exec_requests r 
	CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) a
WHERE r.command in ('BACKUP DATABASE','RESTORE DATABASE', 'BACKUP LOG','RESTORE LOG') 
