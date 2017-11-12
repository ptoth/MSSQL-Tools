DECLARE @command VARCHAR(5000)   
DECLARE @DBInfo TABLE   
(   
DatabaseName VARCHAR(100),   
--PhysicalFileName NVARCHAR(520),   
DBSizeMB DECIMAL(10,2),   
SpaceUsedMB DECIMAL(10,2),   
--FreeSpaceMB DECIMAL(10,2), 
--FreeSpacePct varchar(8)
RecoveryModel VARCHAR(100) 
) 

SELECT @command = 
'Use [' + '?' + '] 

SELECT
    ' + '''' + '?' + '''' + ' AS DatabaseName
    --, filename 
    , convert(decimal(12,2),round(a.size/128.000,2)) as DBSizeMB 
    , convert(decimal(12,2),round(fileproperty(a.name,'+''''+'SpaceUsed'+''''+')/128.000,2)) as SpaceUsedMB 
    --, convert(decimal(12,2),round((a.size-fileproperty(a.name,'+''''+'SpaceUsed'+''''+'))/128.000,2)) as FreeSpaceMB 
    --,CAST(100 * (CAST (((a.size/128.0 -CAST(FILEPROPERTY(a.name,' + '''' + 'SpaceUsed' + '''' + ' ) AS int)/128.0)/(a.size/128.0)) AS decimal(4,2))) AS varchar(8)) + ' + '''' + '%' + '''' + ' AS FreeSpacePct 
    , b.recovery_model_desc AS RecoveryModel
FROM dbo.sysfiles AS a
LEFT JOIN sys.databases AS b ON a.name = b.name COLLATE Hungarian_Technical_CI_AS'

--print @command 
INSERT INTO @DBInfo 
EXEC sp_MSForEachDB @command   

SELECT SERVERPROPERTY('ComputerNamePhysicalNetBIOS') AS HostName
, SERVERPROPERTY('MachineName') AS ServerName
, SERVERPROPERTY('InstanceName') AS InstanceName
, DatabaseName
, SUM(DBSizeMB) AS DBSizeMB
, SUM(SpaceUsedMB) AS SpaceUsedMB
, MAX(RecoveryModel) AS RecoveryModel
from @DBInfo
WHERE DatabaseName NOT IN ('master', 'tempdb', 'model', 'msdb')
group by DatabaseName

