SELECT
	CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,
	msdb.dbo.backupset.database_name,
	msdb.dbo.backupset.backup_start_date,
	msdb.dbo.backupset.backup_finish_date,
	--msdb.dbo.backupset.expiration_date,
	CASE msdb..backupset.type
		WHEN 'D' THEN 'Database'
		WHEN 'I' THEN 'Differential database'
		WHEN 'L' THEN 'Log'
		WHEN 'F' THEN 'File or filegroup'
		WHEN 'G' THEN 'Differential file'
		WHEN 'P' THEN 'Partial'
		WHEN 'Q' THEN 'Differential partial'
	END AS backup_type,
	--msdb.dbo.backupset.backup_size,
	--msdb.dbo.backupmediafamily.logical_device_name,
	--msdb.dbo.backupmediafamily.physical_device_name,
	--msdb.dbo.backupset.name AS backupset_name,
	msdb.dbo.backupset.description
FROM msdb.dbo.backupmediafamily
	INNER JOIN msdb.dbo.backupset
	ON msdb.dbo.backupmediafamily.media_set_id = msdb.dbo.backupset.media_set_id
WHERE (CONVERT(datetime, msdb.dbo.backupset.backup_start_date, 102) >= GETDATE() - 7) -- limit for 7 days
	AND database_name = '<DATABASE_NAME>'
ORDER BY
	--msdb.dbo.backupset.database_name,
	msdb.dbo.backupset.backup_start_date DESC
