/* Print out SQL statements for assigning a role for a specific user on all databases on a given SQL Server */

SET NOCOUNT ON
DECLARE @Accountname nvarchar(100)
SET @Accountname = N'Domain\Username'

DECLARE @Rolename nvarchar(50)
SET @Rolename = N'db_owner'

/* system databases */
DECLARE @SystemDatabases AS TABLE(DBName nvarchar(50))
INSERT INTO @SystemDatabases(DBName) VALUES(N'LiteSpeedLocal')
INSERT INTO @SystemDatabases(DBName) VALUES(N'LightSpeedLocal')

/* get a list of all databases */
DECLARE @Databases AS TABLE(DBName nvarchar(50))
INSERT INTO @Databases(DBName)
SELECT name FROM sys.databases WHERE name NOT IN (SELECT * FROM @SystemDatabases)

/* create the login */
PRINT N'-- Create the login ''' + @Accountname + ''''
PRINT N'USE [master]'
PRINT N'GO'
PRINT N'CREATE LOGIN [' + @Accountname + '] FROM WINDOWS WITH DEFAULT_DATABASE=[master]'
PRINT N'GO'
PRINT N''

/* assign the role to all databases */
DECLARE @Databasename AS nvarchar(50)
WHILE (EXISTS(SELECT TOP 1 DBName FROM @Databases))
BEGIN
	SELECT TOP 1 @Databasename = DBName FROM @Databases

	PRINT N'-- Adding user ''' + @Accountname + ''' to database ''' + @Databasename + ''''
	PRINT  N'USE [' + @Databasename + ']'
	PRINT N'GO'
	PRINT N'CREATE USER [' + @Accountname + '] FOR LOGIN [' + @Accountname + ']'
	PRINT N'GO'
	PRINT N''

	PRINT '-- Assinging ''' + @Rolename +  ''' permissions for user ''' + @Accountname + ''' on database ''' + @Databasename + ''''
	PRINT  N'USE [' + @Databasename + ']'
	PRINT N'GO'
	PRINT N'EXEC sp_addrolemember N''' + @Rolename + ''', N''' + @Accountname + ''''
	PRINT N'GO'
	PRINT N''

	DELETE FROM @Databases WHERE DBName = @Databasename
END