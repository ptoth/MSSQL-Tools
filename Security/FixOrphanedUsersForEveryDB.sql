DECLARE @DatabaseName nvarchar(255)
DECLARE @UserName nvarchar(255) 
DECLARE @Command nvarchar(1000)
DECLARE @SqlStatement nvarchar(4000)

IF OBJECT_ID( 'tempdb..#temp') IS NOT NULL
DROP TABLE tempdb..#temp 
 
CREATE TABLE tempdb..#temp (name VARCHAR(100))

DECLARE database_cur CURSOR FOR 
SELECT sd.name 
FROM sys.databases sd
INNER JOIN (SELECT database_id,collation_name FROm sys.databases WHERE name='master') sd1
ON sd.collation_name=sd1.collation_name AND sd.database_id >4
WHERE sd.user_access=0 
    AND sd.is_read_only=0 
    AND sd.state_desc='ONLINE'  

OPEN database_cur
FETCH NEXT FROM database_cur INTO @DatabaseName

WHILE (@@FETCH_STATUS=0)
BEGIN
SELECT @Command='
    INSERT INTO #temp 
    SELECT UserName = su.name 
    FROM '+quotename(@DatabaseName)+'..sysusers su
    JOIN sys.server_principals sp ON sp.name = su.name
    WHERE issqluser = 1 
        AND (su.sid IS NOT NULL AND su.sid <> 0x0) 
        AND suser_sname(su.sid) is null 
    ORDER BY su.name'

EXEC sp_executesql @command

DECLARE orphan_user_cur CURSOR FOR 
SELECT name FROM #temp WHERE name IS NOT NULL 

IF @@ROWCOUNT=0
BEGIN
    PRINT 'No Orphan User to be fixed for '+@DatabaseName
END

OPEN orphan_user_cur 
FETCH NEXT FROM orphan_user_cur INTO @UserName 

WHILE (@@FETCH_STATUS = 0)
BEGIN 
    PRINT @UserName + 'Orphan User Name Is Being Resynced' 
    EXEC sp_change_users_login 'Update_one', @UserName, @UserName 
    FETCH NEXT FROM orphan_user_cur INTO @UserName 
END 

CLOSE orphan_user_cur 
DEALLOCATE orphan_user_cur

TRUNCATE TABLE #temp 

FETCH NEXT FROM database_cur INTO @DatabaseName
END

CLOSE database_cur 
DEALLOCATE database_cur