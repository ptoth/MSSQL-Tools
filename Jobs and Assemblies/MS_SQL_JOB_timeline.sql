--****************************************************************************************
-- This script returns a (graphical) timeline for all SQL jobs 
-- Execute, and paste the resultset into Excel
--****************************************************************************************
-- Version: 1.0
-- Author:	Theo Ekelmans
-- Email:	theo@ekelmans.com
-- Date:	2013-01-11
--****************************************************************************************

set nocount on 

declare @Minutes table (DT datetime)
declare @JobNames table (JobName varchar(255))
declare @DT datetime 
declare @StartDT datetime 
declare @EndDT datetime 
declare @Resolution int 
declare @RemoveNonactiveJobs int
declare @IgnoreDisabledJobs int

--***************************************************************************************
-- Set variables
--***************************************************************************************
set @StartDT = getdate() - 1 
set @EndDT = getdate()
set @Resolution = 1 -- Enter the Resolution in minutes
set @RemoveNonactiveJobs = 1 
set @IgnoreDisabledJobs = 1

--***************************************************************************************
-- Pre-run cleanup (just in case)
--***************************************************************************************
IF OBJECT_ID('tempdb..#Timeline') IS NOT NULL DROP TABLE #Timeline;
IF OBJECT_ID('tempdb..#JobRuntime') IS NOT NULL DROP TABLE #JobRuntime;
IF OBJECT_ID('tempdb..#Pivot') IS NOT NULL DROP TABLE #Pivot;

--***************************************************************************************
-- Make a Jobname table 
--***************************************************************************************
insert into @JobNames (JobName)
select	replace(name, ' ', '.') --Replace spaces (they are invalid in XML based pivot lower in the code)
from	msdb.dbo.sysjobs
where	enabled = @IgnoreDisabledJobs
--WHERE NAME = '<dbname>'
--WHERE NAME like '%<partial dbname>%'

--***************************************************************************************
-- Genereate a Datetime table between StartDT and EndDT with x minute Resolution
--***************************************************************************************
set @DT = @StartDT

WHILE @DT < @EndDT
	begin
		insert into @Minutes (DT) values(@DT)

		set @DT= dateadd(mi, @Resolution, @DT)
	end

--***************************************************************************************
-- Create a timeline table by crossjoining the Datetime and Jobnames tables
--***************************************************************************************
select DT, JobName, 0 as Active
into #Timeline
from @Minutes cross join @JobNames
 
--***************************************************************************************
-- Create the Job Runtime information table
--***************************************************************************************
select	replace(name, ' ', '.') as name --Replace spaces (they are invalid in XML based pivot lower in the code)
		--,step_id
		--,step_name
		,CONVERT(DATETIME, CONVERT(CHAR(8), run_date, 112) + ' ' + STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), run_time), 6), 5, 0, ':'), 3, 0, ':'), 120) as SDT
		,dateadd(	s,
					((run_duration/10000)%100 * 3600) + ((run_duration/100)%100 * 60) + run_duration%100 ,
					CONVERT(DATETIME, CONVERT(CHAR(8), run_date, 112) + ' ' + STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), run_time), 6), 5, 0, ':'), 3, 0, ':'), 120) 
				) as EDT
		,CAST(STUFF(STUFF(REPLACE(STR(run_duration, 6), ' ', '0'), 3, 0, ':'), 6, 0, ':') AS time(0)) AS Duration
		,((run_duration/10000)%100 * 3600) + ((run_duration/100)%100 * 60) + run_duration%100 DurationSeconds
into	#JobRuntime
FROM	msdb.dbo.sysjobs job 
			left JOIN msdb.dbo.sysjobhistory his
				ON his.job_id = job.job_id

where	CONVERT(DATETIME, CONVERT(CHAR(8), run_date, 112) + ' ' + STUFF(STUFF(RIGHT('000000' + CONVERT(VARCHAR(8), run_time), 6), 5, 0, ':'), 3, 0, ':'), 120) between @StartDT and @EndDT
and		job.name not in ('Database Mirroring Monitor Job', '<dbname>')
and		step_id = 0 -- step_id = 0 is the entrite job, step_id > 0 is actual step number
--and		((run_duration/10000)%100 * 3600) + ((run_duration/100)%100 * 60) + run_duration%100 > 1  -- Ignore trivial runtimes
order by SDT

--***************************************************************************************
-- Update the Timeline based on the the Job Runtime information table
--***************************************************************************************
update	#Timeline
set		Active = 1
from	#Timeline inner join #JobRuntime 
on		JobName = Name
and		(
			SDT between dt and dateadd(mi, @Resolution - 1, DT)  -- Start point (added for Resolution support)
		or  
			EDT between dt and dateadd(mi, @Resolution, DT) -- End point (added for Resolution support)
		or	
			DT  between SDT and EDT
		)

--***************************************************************************************
-- Delete all jobs from the Timeline that that had no activity
--***************************************************************************************
if @RemoveNonactiveJobs = 1 
	delete 
	from	#Timeline
	where	JobName in	(	select	Jobname 
							from	#Timeline
							group by Jobname
							having	sum(active) = 0 )

--***************************************************************************************
-- Pivot the Timeline table
--***************************************************************************************
DECLARE @Minutes2 AS TABLE(col2set varchar(250) NOT NULL PRIMARY KEY)
DECLARE @cols AS nvarchar(MAX)
create table #Pivot (col1 varchar(250) null, col2 varchar(250) null, col3 int null)
-- col1 = row, col2 = column, col3 = data

insert	into #Pivot
select	convert(varchar(250), DT, 120), JobName, Active 
from	#Timeline 

-- Make a table with all unique col2 values 
INSERT INTO @Minutes2 
SELECT DISTINCT col2 
FROM #Pivot

SELECT  @cols = REPLACE(  -- Replace the space in the XML path by a comma
						  -- ([c1] [c2] [c3] [c4]) ->  ([c1],[c2],[c3],[c4])
        ( 
			-- Build the IN clause of the PIVOT by concactenating ([c1] [c2] [c3] [c4])
            SELECT	quotename(col2set) AS [data()] 
            FROM	@Minutes2
            ORDER BY col2set 
            FOR XML PATH ('') 
        ), ' ', ',') 

-- Build the pivot statement as a dyanamic sql statement
DECLARE @sql AS nvarchar(MAX)
SET @sql = N'	
				SELECT col1 as DT,' + @cols + N' 
				FROM (SELECT col1, col2, col3 FROM #Pivot) AS D
				PIVOT(MAX(col3) FOR col2 IN(' + @cols + N')) AS P
				order by col1'

--***************************************************************************************
-- Output the Timeline table
--***************************************************************************************
EXEC sp_executesql @sql

--***************************************************************************************
-- Cleanup
--***************************************************************************************
IF OBJECT_ID('tempdb..#Timeline') IS NOT NULL DROP TABLE #Timeline;
IF OBJECT_ID('tempdb..#JobRuntime') IS NOT NULL DROP TABLE #JobRuntime;
IF OBJECT_ID('tempdb..#Pivot') IS NOT NULL DROP TABLE #Pivot;