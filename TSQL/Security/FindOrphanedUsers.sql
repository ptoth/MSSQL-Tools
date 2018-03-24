/**************************************************
*** Script to find orphaned database users
*** Author: GlutenFreeSQL
*****************************************************/
 
--drop table #DBUsers
DECLARE @DBUsers TABLE 
    ( 
        databasename SYSNAME, 
        username     SYSNAME 
    ) 

INSERT @DBUsers 
EXEC Sp_msforeachdb 
    '
    USE ? 
    select 
        DB_NAME(), 
        name 
    from sysusers 
    where 
        islogin = 1 
        and hasdbaccess = 1 
        and DB_NAME() not in(''msdb'', ''master'', ''tempdb'') 
        and [name] COLLATE DATABASE_DEFAULT not in
        (
            select name 
            from master.dbo.syslogins
        ) 
        and [sid] not in
        (
            select [sid] 
            from master.dbo.syslogins 
        )
        and [name] not in
        (
            select distinct SCHEMA_NAME(schema_id) 
            from sys.objects
        )
    ' 
 
select * from @DBUsers
order by DatabaseName, UserName