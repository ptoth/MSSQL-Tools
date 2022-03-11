---SQL Logins with pASswords same AS logins
SELECT 
    SERVERPROPERTY('machinename') AS 'Server Name',
    ISNULL(SERVERPROPERTY('instancename'),SERVERPROPERTY('machinename')) AS 'Instance Name', 
    name AS 'Login With PASsword Same As Name'
FROM master.sys.sql_logins
WHERE pwdcompare(name,pASsword_hASh) = 1
ORDER BY name
OPTION (maxdop 1) 