BACKUP DATABASE [OperationsManager] TO DISK =
N'D:\SQL\MSSQL10_50.DEVSCOM01\MSSQL\Backup\SCOMAlerts_20170202.bak' WITH
copy_only, noformat, noinit, NAME = N'SCOMAlerts-Full Database Backup', skip,
norewind, nounload, compression, stats = 10

go

DECLARE @backupSetId AS INT

SELECT @backupSetId = position
FROM   msdb..backupset
WHERE  database_name = N'SCOMAlerts'
       AND backup_set_id = (SELECT Max(backup_set_id)
                            FROM   msdb..backupset
                            WHERE  database_name = N'SCOMAlerts')

IF @backupSetId IS NULL
  BEGIN
      RAISERROR(
N'Verify failed. Backup information for database ''SCOMAlerts'' not found.',
16,1)
END

RESTORE verifyonly FROM DISK =
N'D:\SQL\MSSQL10_50.DEVSCOM01\MSSQL\Backup\SCOMAlerts_20170202.bak' WITH FILE =
@backupSetId, nounload, norewind

go 