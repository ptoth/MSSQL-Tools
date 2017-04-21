SELECT @@SPID

SELECT session_id, encrypt_option
FROM sys.dm_exec_connections
