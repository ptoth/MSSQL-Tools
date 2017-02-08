-- Query MSSQL job details
SELECT	CONVERT(CHAR(30), SERVERPROPERTY('servername')) ServerName,
		j.name,
		s.name,
		j.enabled,
		j.description
FROM  msdb..sysjobs j
	LEFT JOIN master.sys.syslogins s 
		ON j.owner_sid = s.sid
WHERE s.name != 'sa'

-- Alter MSSQL job owner
--exec msdb..sp_update_job @job_name = 'job_name', @owner_login_name = 'sa'