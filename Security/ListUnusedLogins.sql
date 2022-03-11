/**************************************************
*** Script to find unused logins
*** Author: GlutenFreeSQL
*****************************************************/
DECLARE @DBLogins TABLE 
(
    username SYSNAME,
    usersid VARBINARY(85) 
)

INSERT INTO @DBLogins
EXEC Sp_msforeachdb 'USE ? SELECT [name], sid from sys.database_principals WHERE type <> ''R'' '

USE master

SELECT NAME
FROM syslogins
WHERE [name] NOT IN
    (
        SELECT DISTINCT username
        FROM @DBLogins
    )
    AND [sid] NOT IN
    (
        SELECT DISTINCT usersid
        FROM @DBLogins
        WHERE usersid IS NOT NULL
    )
    AND sysadmin <> 1
    AND hasaccess = 1 
 
/*
--Check for jobs owned by user before deleting any
select distinct SUSER_SNAME(owner_sid)
from msdb.dbo.sysjobs
 
select SUSER_SNAME(owner_sid), *
from msdb.dbo.sysjobs
WHERE SUSER_SNAME(owner_sid) &lt;&gt; 'sa'
*/