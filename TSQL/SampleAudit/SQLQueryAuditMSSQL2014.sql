SELECT name,
CAST(value as int) as value_configured,
CAST(value_in_use as int) as value_in_use
FROM sys.configurations
WHERE name = 'Cross db ownership chaining';

SELECT name,
CAST(value as int) as value_configured,
CAST(value_in_use as int) as value_in_use
FROM sys.configurations
WHERE name = 'Database Mail XPs';

SELECT name,
CAST(value as int) as value_configured,
CAST(value_in_use as int) as value_in_use
FROM sys.configurations
WHERE name = 'Ole Automation Procedures';

SELECT name,
CAST(value as int) as value_configured,
CAST(value_in_use as int) as value_in_use
FROM sys.configurations
WHERE name = 'Remote access';

USE master;
GO
SELECT name,
CAST(value as int) as value_configured,
CAST(value_in_use as int) as value_in_use
FROM sys.configurations
WHERE name = 'Remote admin connections'
AND SERVERPROPERTY('IsClustered') = 0;

SELECT name,
CAST(value as int) as value_configured,
CAST(value_in_use as int) as value_in_use
FROM sys.configurations
WHERE name = 'Scan for startup procs';


SELECT name
FROM sys.databases
WHERE is_trustworthy_on = 1
AND name != 'msdb'
AND state = 0;


SELECT name, is_disabled
FROM sys.server_principals
WHERE sid = 0x01;

SELECT name
FROM sys.server_principals
WHERE sid = 0x01;

EXECUTE sp_configure 'show advanced options',1;
RECONFIGURE WITH OVERRIDE;
EXECUTE sp_configure 'xp_cmdshell';


SELECT name, containment, containment_desc, is_auto_close_on
FROM sys.databases
WHERE containment <> 0 and is_auto_close_on = 1;



SELECT DB_NAME() AS DBName, dpr.name, dpe.permission_name
FROM sys.database_permissions dpe
JOIN sys.database_principals dpr
ON dpe.grantee_principal_id=dpr.principal_id
WHERE dpr.name='guest'
AND dpe.permission_name='CONNECT';





SELECT name AS DBUser
FROM sys.database_principals
WHERE name NOT IN ('dbo','Information_Schema','sys','guest')
AND type IN ('U','S','G')
AND authentication_type = 2;
GO


SELECT SQLLoginName = sp.name
FROM sys.server_principals sp
JOIN sys.sql_logins AS sl
ON sl.principal_id = sp.principal_id
WHERE sp.type_desc = 'SQL_LOGIN'
AND sp.name in
(SELECT name AS IsSysAdmin
FROM sys.server_principals p
WHERE IS_SRVROLEMEMBER('sysadmin',name) = 1)
AND sl.is_expiration_checked <> 1;


SELECT SQLLoginName = sp.name,
PasswordPolicyEnforced = CAST(sl.is_policy_checked AS BIT)
FROM sys.server_principals sp
JOIN sys.sql_logins AS sl ON sl.principal_id = sp.principal_id
WHERE sp.type_desc = 'SQL_LOGIN';


SELECT name,
CAST(value as int) as value_configured,
CAST(value_in_use as int) as value_in_use
FROM sys.configurations
WHERE name = 'Default trace enabled';