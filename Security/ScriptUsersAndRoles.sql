/* THIS SCRIPT IWLL GENERATE THE LOGINS AND DATABASE USER INFORMATION.
   SCRIPT CAN BE USED TO GATHER DATABASE USER INFORMATION PRIOR TO DATA REFRESH. 
This script will generate the Logins and Database user information in a SQL Server. 
This script can be used to gather Database user information prior to data refresh. A where cluase for that database name should be added to the script*/


IF  EXISTS (SELECT *
FROM tempdb.dbo.sysobjects
WHERE name = '##Users' AND type in (N'U'))
    DROP TABLE ##Users
IF  EXISTS (SELECT *
FROM tempdb.dbo.sysobjects
WHERE name = '##LOGINS' AND type in (N'U'))
    DROP TABLE ##LOGINS
GO

USE tempdb
GO
/*CREATE TABLE ##LOGINS
(
   [Login Name]         varchar(50),   
    [Default Database]      varchar(60),   
    [Login Type]         varchar(40),   
    [AD Login Type]         varchar(40),   
    [sysadmin]            char(5),   
    [securityadmin]         char(5),   
    [serveradmin]         char(5),   
    [setupadmin]         char(5),   
    [processadmin]         char(5),   
    [diskadmin]            char(5),   
    [dbcreator]            char(5),   
    [bulkadmin]            char(5)
)*/
CREATE TABLE ##Users
(
    [Database] VARCHAR(64),
    [Database User ID] VARCHAR(64),
    [Server Login] VARCHAR(64),
    [Database Role] VARCHAR(64)
)
use master
go
SELECT sid,
    loginname AS [Login Name],
    dbname AS [Default Database],
    CASE isntname 
            WHEN 1 THEN 'AD Login'
            ELSE 'SQL Login'
        END AS [Login Type],
    CASE 
            WHEN isntgroup = 1 THEN 'AD Group'
            WHEN isntuser = 1 THEN 'AD User'
            ELSE ''
        END AS [AD Login Type],
    CASE sysadmin
            WHEN 1 THEN 'Yes'
            ELSE 'No'
        END AS [sysadmin],
    CASE [securityadmin]
            WHEN 1 THEN 'Yes'
            ELSE 'No'
        END AS [securityadmin],
    CASE [serveradmin]
            WHEN 1 THEN 'Yes'
            ELSE 'No'
        END AS [serveradmin],
    CASE [setupadmin]
            WHEN 1 THEN 'Yes'
            ELSE 'No'
        END AS [setupadmin],
    CASE [processadmin]
            WHEN 1 THEN 'Yes'
            ELSE 'No'
        END AS [processadmin],
    CASE [diskadmin]
            WHEN 1 THEN 'Yes'
            ELSE 'No'
        END AS [diskadmin],
    CASE [dbcreator]
            WHEN 1 THEN 'Yes'
            ELSE 'No'
        END AS [dbcreator],
    CASE [bulkadmin]
            WHEN 1 THEN 'Yes'
            ELSE 'No'
        END AS [bulkadmin]
INTO ##LOGINS
FROM dbo.syslogins
/*IN ORDER TO GET THE ACCESS INFORMATION A LOGIN ADD THE LOGIN NAME TO THE WHERE CLUASE BELOW*/
--WHERE [LOGINNAME] = 'PUNCH IN THE LOGIN NAME HERE'

SELECT [Login Name],
    [Default Database],
    [Login Type],
    [AD Login Type],
    [sysadmin],
    [securityadmin],
    [serveradmin],
    [setupadmin],
    [processadmin],
    [diskadmin],
    [dbcreator],
    [bulkadmin]
FROM tempdb..##LOGINS
ORDER BY [Login Type], [AD Login Type], [Login Name]


USE master
GO

DECLARE @DBName             VARCHAR(60)
DECLARE @SQLCmd             VARCHAR(1024)
Declare @DBID            varchar(3)

set @DBID = (select MAX(database_id)
from sys.databases)
--print @DBID
WHILE @DBID != 0
BEGIN
    set @DBName = (select DB_NAME (''+@DBID+''))
    SELECT @SQLCmd = 'INSERT ##Users ' +
                         '  SELECT ''' + @DBName + ''' AS [Database],' +
                         '       su.[name] AS [Database User ID], ' +
                         '       COALESCE (u.[Login Name], ''** Orphaned **'') AS [Server Login], ' +
                         '       COALESCE (sug.name, ''Public'') AS [Database Role] ' +
                         '    FROM [' + @DBName + '].[dbo].[sysusers] su' +
                         '        LEFT OUTER JOIN ##LOGINS u' +
                         '            ON su.sid = u.sid' +
                         '        LEFT OUTER JOIN ([' + @DBName + '].[dbo].[sysmembers] sm ' +
                         '                             INNER JOIN [' + @DBName + '].[dbo].[sysusers] sug  ' +
                         '                                 ON sm.groupuid = sug.uid)' +
                         '            ON su.uid = sm.memberuid ' +
                         '    WHERE su.hasdbaccess = 1' +
                         '      AND su.[name] != ''dbo'' '
    print @DBName
    EXEC (@SQLCmd)
    print @DBID
    set @DBID = @DBID - 1
END




SELECT *
FROM ##Users
/*IN ORDER TO GET THE ACCESS INFORMATION A USER ADD THE USER TO THE WEHRE CLUASE BELOW*/
--WHERE [Database User ID] = 'PUNCH IN THE USER HERE'
/*IN ORDER TO GET THE ACCESS INFORMATION OF ALL USERS TO A PARTICULAR DATABASE, ADD THE DATABASE NAME TO THE WHERE CLUASE BELOW*/
--WHERE [DATABASE] = 'PUNCH IN YOUR DATABASE NAME HERE'
ORDER BY [Database], [Database User ID]

IF  EXISTS (SELECT *
FROM tempdb.dbo.sysobjects
WHERE name = '##LOGINS' AND type in (N'U'))
    DROP TABLE ##LOGINS

GO
IF  EXISTS (SELECT *
FROM tempdb.dbo.sysobjects
WHERE name = '##Users' AND type in (N'U'))
    DROP TABLE ##Users
    
GO
