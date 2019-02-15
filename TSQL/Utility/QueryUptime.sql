SET NOCOUNT ON

DECLARE @crdate DATETIME, @hr VARCHAR(50), @min VARCHAR(5)

SELECT @crdate = crdate
FROM sysdatabases
WHERE NAME = 'tempdb'

SELECT @hr = (DATEDIFF ( mi, @crdate,GETDATE())) / 60
IF ((DATEDIFF ( mi, @crdate,GETDATE())) / 60) = 0
        SELECT @min = (DATEDIFF ( mi, @crdate,GETDATE()))
    ELSE
        SELECT @min = (DATEDIFF ( mi, @crdate,GETDATE())) - ((DATEDIFF( mi, @crdate,GETDATE())) / 60)*60

PRINT 'SQL Server "' + CONVERT(VARCHAR(20),SERVERPROPERTY('SERVERNAME')) + '" is Online for the past ' + @hr + ' hours & ' + @min + ' minutes'
IF NOT EXISTS (SELECT 1
FROM master.dbo.sysprocesses
WHERE program_name =  N'SQLAgent - Generic Refresher')
BEGIN
    PRINT 'SQL Server is running but SQL Server Agent <<NOT>> running'
END
ELSE
BEGIN
    PRINT 'SQL Server and SQL Server Agent both are running'
END


-- For 2008:
/*
SET NOCOUNT ON

DECLARE @crdate DATETIME, @hr VARCHAR(50), @min VARCHAR(5)

SELECT @crdate = create_date
FROM sys.databases
WHERE name = 'tempdb'

SELECT @hr = (DATEDIFF ( mi, @crdate,GETDATE())) / 60
    IF ((DATEDIFF ( mi, @crdate,GETDATE())) / 60) = 0
        SELECT @min = (DATEDIFF ( mi, @crdate,GETDATE()))
    ELSE
        SELECT @min = (DATEDIFF ( mi, @crdate,GETDATE())) - ((DATEDIFF( mi, @crdate,GETDATE())) / 60)*60

PRINT 'SQL Server "' + CONVERT(VARCHAR(20),SERVERPROPERTY('SERVERNAME')) + '" is Online for the past ' + @hr + ' hours & ' + @min + ' minutes'
    IF NOT EXISTS (SELECT 1 FROM master.dbo.sysprocesses WHERE program_name =  N'SQLAgent - Generic Refresher')
        BEGIN
            PRINT 'SQL Server is running but SQL Server Agent <<NOT>> running'
        END
    ELSE
        BEGIN
            PRINT 'SQL Server and SQL Server Agent both are running'
        END
*/