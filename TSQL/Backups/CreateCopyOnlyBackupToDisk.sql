BACKUP DATABASE [Database] TO DISK =
N'D:\SQL\Backup.bak' WITH
copy_only, noformat, noinit, NAME = N'Full Database Backup', skip,
norewind, nounload, compression, stats = 10

GO
DECLARE @backupSetId AS INT

SELECT @backupSetId = position
FROM msdb..backupset
WHERE database_name = N'Database'
  AND backup_set_id =
  (
    SELECT Max(backup_set_id)
    FROM msdb..backupset
    WHERE database_name = N'Database'
  )

IF @backupSetId IS NULL
  BEGIN
  RAISERROR(
      N'Verify failed. Backup information for database ''Database'' not found.',16,1)
  END

RESTORE verifyonly FROM DISK =
N'D:\SQL\Backup.bak' WITH FILE =
@backupSetId, nounload, norewind

GO
