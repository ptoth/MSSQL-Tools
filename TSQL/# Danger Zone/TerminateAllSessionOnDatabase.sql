-- To Check:
--kill <SPID> with statusonly

--For MS SQL Server 2012 and above

USE [master];

DECLARE @kill varchar(8000) = '';
SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), session_id) + ';'
FROM sys.dm_exec_sessions
WHERE database_id  = db_id('MyDB')

EXEC(@kill);

--For MS SQL Server 2000, 2005, 2008
USE master;

DECLARE @kill varchar(8000); SET @kill = '';
SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), spid) + ';'
FROM master..sysprocesses
WHERE dbid = db_id('MyDB')

EXEC(@kill);
