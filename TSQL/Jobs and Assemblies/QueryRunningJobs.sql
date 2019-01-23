SELECT
     job.job_id,
     notify_level_email,
     name,
     enabled,
     description,
     step_name,
     command,
     server,
     database_name
FROM
    msdb.dbo.sysjobs job
INNER JOIN 
    msdb.dbo.sysjobsteps steps        
ON
    job.job_id = steps.job_id
--WHERE
--    job.enabled = 1 -- remove this if you wish to return all jobs
