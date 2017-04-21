/*Query owner of tha databases */
SELECT NAME AS DataBaseName,
	SUSER_SNAME(owner_sid) AS OwnerUser
FROM sys.databases
WHERE SUSER_SNAME(owner_sid) != 'sa'
ORDER BY databasename;

/* Execute altering SP for all database */
--EXEC sp_MSforeachdb 'EXEC [?]..sp_changedbowner ''sa'' '
SELECT	@@SERVERNAME AS DB,
	NAME AS DataBaseName,
	SUSER_SNAME(owner_sid) AS OwnerUser
FROM sys.databases
WHERE SUSER_SNAME(owner_sid) != 'sa'
	AND SUSER_SNAME(owner_sid) != 'Domain\User'
	AND SUSER_SNAME(owner_sid) != 'Domain\User'
	AND SUSER_SNAME(owner_sid) != 'Domain\User'
	AND SUSER_SNAME(owner_sid) != 'Domain\User'
ORDER BY db DESC;

--USE Database; EXEC [Database]..sp_changedbowner 'sa';

SELECT 'ALTER SCHEMA dbo TRANSFER [' + s.Name + '].[' + o.Name +']'
    FROM sys.Objects o
        INNER JOIN sys.Schemas s ON o.schema_id = s.schema_id
    WHERE s.Name = 'Domain\User'
AND (o.Type = 'U' OR o.Type = 'P' OR o.Type = 'V')
