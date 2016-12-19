SELECT	db.name,
		db.recovery_model_desc,
		MAX(backupset.backup_finish_date) AS backup_finish_date
FROM 	master.sys.databases db
LEFT OUTER JOIN msdb..backupset backupset
		ON backupset.database_name = db.name
	AND backupset.type = 'L'
WHERE	db.name = '<database_name>'
GROUP BY db.name, db.recovery_model_desc
ORDER BY backup_finish_date DESC
