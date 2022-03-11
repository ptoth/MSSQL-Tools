USE [Database]
GO

DECLARE @FileName sysname = N'Database';
DECLARE @TargetSize INT = (SELECT 1 + size*8./1024 FROM sys.database_files WHERE name = @FileName);
DECLARE @Factor FLOAT = .999;

WHILE @TargetSize > 3500000
BEGIN
    SET @TargetSize *= @Factor;
    DBCC SHRINKFILE(@FileName, @TargetSize);
    DECLARE @msg VARCHAR(200) = CONCAT('Shrink file completed. Target Size: ',
    @TargetSize, ' MB. Timestamp: ', CURRENT_TIMESTAMP);
    RAISERROR(@msg, 1, 1) WITH NOWAIT;
    WAITFOR DELAY '00:00:05';
END;