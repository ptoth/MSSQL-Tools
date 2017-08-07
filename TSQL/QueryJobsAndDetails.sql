-- Query MSSQL job details
SELECT CONVERT(NVARCHAR(128), Serverproperty('Servername')) AS server,
    msdb.dbo.sysjobs.job_id,
    msdb.dbo.sysjobs.NAME,
    msdb.dbo.sysjobs.enabled AS job_enabled,
    msdb.dbo.sysjobs.description,
    msdb.dbo.sysjobs.notify_level_eventlog,
    msdb.dbo.sysjobs.notify_level_email,
    msdb.dbo.sysjobs.notify_level_netsend,
    msdb.dbo.sysjobs.notify_level_page,
    msdb.dbo.sysjobs.notify_email_operator_id,
    msdb.dbo.sysjobs.date_created,
    msdb.dbo.syscategories.NAME AS category_name,
    msdb.dbo.sysjobschedules.next_run_date,
    msdb.dbo.sysjobschedules.next_run_time,
    msdb.dbo.sysjobservers.last_run_outcome,
    msdb.dbo.sysjobservers.last_outcome_message,
    msdb.dbo.sysjobservers.last_run_date,
    msdb.dbo.sysjobservers.last_run_time,
    msdb.dbo.sysjobservers.last_run_duration,
    msdb.dbo.sysoperators.NAME AS notify_operator,
    msdb.dbo.sysoperators.email_address,
    msdb.dbo.sysjobs.date_modified,
    Getdate() AS package_run_date,
    msdb.dbo.sysschedules.NAME AS schedule_name,
    msdb.dbo.sysschedules.enabled,
    msdb.dbo.sysschedules.freq_type,
    msdb.dbo.sysschedules.freq_interval,
    msdb.dbo.sysschedules.freq_subday_interval,
    msdb.dbo.sysschedules.freq_subday_type,
    msdb.dbo.sysschedules.freq_relative_interval,
    msdb.dbo.sysschedules.freq_recurrence_factor,
    msdb.dbo.sysschedules.active_start_date,
    msdb.dbo.sysschedules.active_end_date,
    msdb.dbo.sysschedules.active_start_time,
    msdb.dbo.sysschedules.active_end_time,
    msdb.dbo.sysschedules.date_created  AS date_sched_created,
    msdb.dbo.sysschedules.date_modified AS date_sched_modified,
    msdb.dbo.sysschedules.version_number,
    msdb.dbo.sysjobs.version_number AS job_version
FROM msdb.dbo.sysjobs
    INNER JOIN msdb.dbo.syscategories ON msdb.dbo.sysjobs.category_id = msdb.dbo.syscategories.category_id
    LEFT OUTER JOIN msdb.dbo.sysoperators ON msdb.dbo.sysjobs.notify_page_operator_id = msdb.dbo.sysoperators.id
    LEFT OUTER JOIN msdb.dbo.sysjobservers ON msdb.dbo.sysjobs.job_id = msdb.dbo.sysjobservers.job_id
    LEFT OUTER JOIN msdb.dbo.sysjobschedules ON msdb.dbo.sysjobschedules.job_id = msdb.dbo.sysjobs.job_id
    LEFT OUTER JOIN msdb.dbo.sysschedules ON msdb.dbo.sysjobschedules.schedule_id = msdb.dbo.sysschedules.schedule_id
