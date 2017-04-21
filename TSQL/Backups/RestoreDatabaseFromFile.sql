USE [master]
RESTORE DATABASE [Database] 
    FROM  DISK = N'C:\BACKUP.bak'
    WITH  FILE = 1,
    MOVE N'DB_DATA' TO N'D:\Database.mdf',
    MOVE N'DB_LOG' TO N'D:\Log.ldf',
    NOUNLOAD,  REPLACE,  STATS = 5
GO
