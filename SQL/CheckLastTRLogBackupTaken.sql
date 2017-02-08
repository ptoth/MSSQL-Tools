SELECT db.NAME,
       db.recovery_model_desc,
       Max(backupset.backup_finish_date) AS backup_finish_date
FROM   master.sys.databases db
       LEFT OUTER JOIN msdb..backupset backupset
                    ON backupset.database_name = db.NAME
                       AND backupset.type = 'L'
-- if you check for TRNLog backup
WHERE  db.NAME = '<database_name>'
GROUP  BY db.NAME,
          db.recovery_model_desc
ORDER  BY backup_finish_date DESC 