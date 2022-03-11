USE master

DECLARE @LoginName sysname
DECLARE @SQL NVARCHAR(1000)

DECLARE DBLOGINS CURSOR FOR
    SELECT name
	FROM sys.server_principals 
	WHERE name LIKE 'Domain\%'
	ORDER BY 1

OPEN DBLOGINS

FETCH NEXT FROM DBLOGINS INTO @LoginName
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @SQL = 'DROP LOGIN [' + @LoginName + ']'
    EXEC sp_executesql @SQL
    FETCH NEXT FROM DBLOGINS INTO @LoginName
END

CLOSE DBLOGINS
DEALLOCATE DBLOGINS


--To see which database needs to be altered to SA
SELECT suser_sname( owner_sid ), name, 'ALTER AUTHORIZATION ON DATABASE::['+name+'] TO sa;'
FROM sys.databases
WHERE database_id > 4
	AND suser_sname( owner_sid ) != 'sa'

--To see which jobs need to be altered to SA
SELECT s.name,l.name
FROM msdb..sysjobs s
LEFT JOIN master.sys.syslogins l on s.owner_sid = l.sid

-- granted permission
SELECT class_desc,*
FROM sys.server_permissions
WHERE grantor_principal_id = (
    SELECT principal_id
    FROM sys.server_principals
    WHERE NAME = N'<USERNAME>'
)

SELECT NAME
    ,type_desc
FROM sys.server_principals
WHERE principal_id IN (
    SELECT grantee_principal_id
    FROM sys.server_permissions
    WHERE grantor_principal_id = (
        SELECT principal_id
        FROM sys.server_principals
        WHERE NAME = N'<USERNAME>'
        )
    )