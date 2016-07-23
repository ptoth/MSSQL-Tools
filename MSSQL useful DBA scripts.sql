/*
Useful MSSQL command from:
http://www.databasejournal.com/features/mssql/article.php/3923371/Top-10-Transact-SQL-Statements-a-SQL-Server-DBA-Should-Know.htm
*/

--T-SQL Statement 1
/*
The following T-SQL statement retrieves information such as Hostname,
Current instance name, Edition, Server type, ServicePack and
version number from current SQL Server connection.
'Edition' will give information on a 32 bit or 64 bit architecture
and 'Productlevel' gives information about what service pack
your SQL Server is on. It also displays
if the current SQL Server is a clustered server.
*/

SELECT
          SERVERPROPERTY('MachineName') as Host,
          SERVERPROPERTY('InstanceName') as Instance,
          SERVERPROPERTY('Edition') as Edition, /*shows 32 bit or 64 bit*/
          SERVERPROPERTY('ProductLevel') as ProductLevel, /* RTM or SP1 etc*/
          Case SERVERPROPERTY('IsClustered') when 1 then 'CLUSTERED' else
      'STANDALONE' end as ServerType,
          @@VERSION as VersionNumber

--T-SQL Statement 2
/*
Server level configuration controls some of the features and
performance of SQL Server.
It is also important for a SQL Server DBA to know the server level
configuration information.
The following SQL Statement will give all of the information
related to Server level configuration.
*/

SELECT * from sys.configurations order by NAME

--T-SQL Statement 3
/*
Security is a very important aspect that a DBA should know about.
It is also important to know which login has a sysadmin or security
admin server level role.
The following SQL Command will show information related to the security
admin server role and system admin server role.
*/

SELECT l.name, l.denylogin, l.isntname, l.isntgroup, l.isntuser
  FROM master.dbo.syslogins l
WHERE l.sysadmin = 1 OR l.securityadmin = 1

--T-SQL Statement 4
/*
Another important bit of information that you need to know as a DBA is all
of the traces that are enabled.
The following T-SQL statement will list all of the trace flags
that are enabled gloabally on the server.
*/

DBCC TRACESTATUS(-1);
--The following T-SQL statement will list all the trace flags that are enabled on the current sql server connection. Refer Fig 1.4
DBCC TRACESTATUS();

/* Database Level Transact-SQL Statements a SQL Server DBA should know */

--T-SQL Statement 5
/*
Getting Database level information is equally as important as Server level
information. The following T-SQL statement gives information on the database
names, their compatibility level and also the recovery model and their
current status.
The result from this T-SQL Statement will help you to determine if there
is any compatibility level update necessary.
When upgrading from an older version to new version, the compatibility level
of the database may not be in the desired level. The following statement will
help you to list all of the database names with compatibilty level.
It also lists the online/offline status of the database as well as helping
the DBA to see if any update to recovery model is necessary.
*/

SELECT name,compatibility_level,recovery_model_desc,state_desc  FROM sys.databases

--T-SQL Statement 6
/*
The next level of information related to database that is needed is the
location of the database. The following T-SQL Statement provides the logical
name and the physical location of the data/log files of all the databases
available in the current SQL Server instance.
*/

SELECT db_name(database_id) as DatabaseName,name,type_desc,physical_name FROM sys.master_files

--T-SQL Statement 7
/*
A database may contain filegroups other than the primary file group.
The following T-SQL Statement gets executed in each database on the server
and displays the file groups related results.
*/

EXEC master.dbo.sp_MSforeachdb @command1 = 'USE [?] SELECT * FROM sys.filegroups'

/* Backup Level Transact-SQL Statements a SQL Server DBA should know */

--T-SQL Statement 8
/*
Backup of a database is bread and butter for database administrators.
The following T-SQL Statement lists all of the databases in the server and
the last day the backup happened.
This will help the database administrators to check the backup jobs and
also to make sure backups are happening for all the databases.
*/

SELECT db.name,
case when MAX(b.backup_finish_date) is NULL then 'No Backup' else convert(varchar(100),
	MAX(b.backup_finish_date)) end AS last_backup_finish_date
FROM sys.databases db
LEFT OUTER JOIN msdb.dbo.backupset b ON db.name = b.database_name AND b.type = 'D'
	WHERE db.database_id NOT IN (2)
GROUP BY db.name
ORDER BY 2 DESC

--T-SQL Statement 9
/*
The next level of information that is important for a SQL Server database
administrator to know is the location of all the backup files.
You don’t want the backups to go to the local drive or to an OS drive.
The following T-SQL statement gets all the information related to the current
backup location from the msdb database.
*/

SELECT Distinct physical_device_name FROM msdb.dbo.backupmediafamily

/* Process Level Transact-SQL Statements a SQL Server DBA should know */

--T-SQL Statement 10
/*
Last but not least, is the information related to current processes and
connection related information. From the beginning, SQL Server database
administrators used sp_who and sp_who2 to check the current users, process
and session information.
These statements also provided information related to cpu, memory and
blocking information related to the sessions.

Also, search the internet for sp_who3.
*/

sp_who
sp_who2

--T-SQL Statement 11
/*
Here is a script to finding info on a database:
MDF, NDF and LDF files - enjoy.
*/

SELECT SERVERPROPERTY('ComputerNamePhysicalNetBios') as 'Is_Current_Owner',
    SERVERPROPERTY('MachineName') as 'MachineName',
    @@servername as '@@servername',
    DB_NAME() as 'Use_Name',
    sysfilegroups.groupid,
    sysfilegroups.groupname,
    fileid,
    convert(decimal(12,2),round(sysfiles.size/128.000,2)) as 'File_size_(MB)',
    convert(decimal(12,2),round(fileproperty(sysfiles.name,'SpaceUsed')/128.000,2)) as 'Space_used(MB)',
    convert(decimal(12,2),round((sysfiles.size-fileproperty(sysfiles.name,'SpaceUsed'))/128.000,2)) as 'Free_space(MB)',
    cast((convert(decimal(12,2),round(fileproperty(sysfiles.name,'SpaceUsed')/128.000,2))/ convert(decimal(12,2),round(sysfiles.size/128.000,2))) * 100 as decimal(12,3)) as pct_USED,
    cast((convert(decimal(12,2),round((sysfiles.size-fileproperty(sysfiles.name,'SpaceUsed'))/128.000,2)) / convert(decimal(12,2),round(sysfiles.size/128.000,2)) ) *100 as decimal(12,3)) as pct_free_space,
    sysfiles.name ,sysfiles.filename
FROM dbo.sysfiles sysfiles
LEFT OUTER JOIN dbo.sysfilegroups sysfilegroups ON sysfiles.groupid = sysfilegroups.groupid;
