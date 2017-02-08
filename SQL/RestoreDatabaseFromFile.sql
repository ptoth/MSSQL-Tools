USE [master]
RESTORE DATABASE [OperationsManager] 
    FROM  DISK = N'C:\DEVSCOM_BACKUPS\OperationsManager_20170202.bak' 
    WITH  FILE = 1,  
    MOVE N'MOM_DATA' TO N'D:\MSSQL13.DEVSCOM01\MSSQL\DATA\OperationsManager.mdf',  
    MOVE N'MOM_LOG' TO N'D:\MSSQL13.DEVSCOM01\MSSQL\DATA\OperationsManager.ldf',  
    NOUNLOAD,  REPLACE,  STATS = 5
GO


