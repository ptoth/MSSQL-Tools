SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server,   
	main.name Database_name,
	main.recovery_model_desc, 
	fullbk.FULL_last_db_backup_date, 
	fullbk.FULL_Backup_Age_In_Hours, 
	diffbk.DIFF_last_db_backup_date, 
	diffbk.DIFF_Backup_Age_In_Hours, 
	logbk.LOG_last_db_backup_date, 
	logbk.LOG_Backup_Age_In_Hours

FROM sys.databases main 
LEFT OUTER JOIN
	(
		SELECT msdb.dbo.backupset.database_name as DB_names, 
			MAX(msdb.dbo.backupset.backup_finish_date) AS FULL_last_db_backup_date, 
			DATEDIFF(hh, MAX(msdb.dbo.backupset.backup_finish_date), GETDATE()) AS FULL_Backup_Age_In_Hours
		FROM msdb.dbo.backupset   
		WHERE   msdb.dbo.backupset.type = 'D'  
			and msdb.dbo.backupset.database_name in (select name from sys.databases)  
		GROUP BY msdb.dbo.backupset.database_name
	) fullbk on main.name = fullbk.DB_names
	
LEFT OUTER JOIN
	(
		SELECT msdb.dbo.backupset.database_name as DIFF_names, 
			MAX(msdb.dbo.backupset.backup_finish_date) AS DIFF_last_db_backup_date, 
			DATEDIFF(hh, MAX(msdb.dbo.backupset.backup_finish_date), GETDATE()) AS DIFF_Backup_Age_In_Hours
		FROM msdb.dbo.backupset   
		WHERE   msdb.dbo.backupset.type = 'I'  
		and msdb.dbo.backupset.database_name in (select name from sys.databases)  
		GROUP BY msdb.dbo.backupset.database_name
	) diffbk on fullbk.DB_names = diffbk.DIFF_names

LEFT OUTER JOIN
	(
		SELECT msdb.dbo.backupset.database_name as DIFF_names, 
			MAX(msdb.dbo.backupset.backup_finish_date) AS LOG_last_db_backup_date, 
			DATEDIFF(hh, MAX(msdb.dbo.backupset.backup_finish_date), GETDATE()) AS LOG_Backup_Age_In_Hours
		FROM msdb.dbo.backupset   
		WHERE   msdb.dbo.backupset.type = 'L'  
		and msdb.dbo.backupset.database_name in (select name from sys.databases)  
		GROUP BY msdb.dbo.backupset.database_name
	) logbk on diffbk.DIFF_names = logbk.DIFF_names