DECLARE @DBName SYSNAME;
SET @DBName = DB_NAME();
-- modify these as you desire.
SET @DBName = NULL;
-- comment this line if you want to limit the displayed history

SELECT
	ServerName = bs.server_name,
	DatabaseName = bs.database_name,
	RecoveryModel = bs.recovery_model,
	BackupStartDate = bs.backup_start_date,
	CompressedBackupSize = bs.compressed_backup_size,
	BackupType = 
		CASE bs.type 
			WHEN 'D' THEN 'Database'
			WHEN 'I' THEN 'Differential database'
			WHEN 'L' THEN 'Log'
			WHEN 'F' THEN 'File or filegroup'
			WHEN 'G' THEN 'Differential file'
			WHEN 'P' THEN 'Partial'
			WHEN 'Q' THEN 'Differential partial'
			ELSE '[unknown]' END,
	--ExpirationDate = bs.expiration_date,
	--BackupSetName = bs.name,
	--LogicalDeviceName = bmf.logical_device_name,
	PhysicalDeviceName = bmf.physical_device_name
FROM msdb.dbo.backupset bs
	INNER JOIN msdb.dbo.backupmediafamily bmf
	ON [bs].[media_set_id] = [bmf].[media_set_id]
WHERE bs.database_name = '<DATABASE_NAME>'
ORDER BY bs.backup_start_date DESC;
