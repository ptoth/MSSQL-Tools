/*
This script is used to shrink a database file in
increments until it reaches a target free space limit.
Run this script in the database with the file to be shrunk.
1. Set @DBFileName to the name of database file to shrink.
2. Set @TargetFreeMB to the desired file free space in MB after shrink.
3. Set @ShrinkIncrementMB to the increment to shrink file by in MB
4. Run the script
*/
SET nocount on
DECLARE @DBFileName sysname
DECLARE @TargetFreeMB int
DECLARE @ShrinkIncrementMB int
-- Set Name of Database file to shrink
SET @DBFileName = 'Database'
-- Set Desired file free space in MB after shrink
SET @TargetFreeMB = 102400
-- Set Increment to shrink file by in MB
SET @ShrinkIncrementMB = 1024
-- Show Size, Space Used, Unused Space, and Name of all database files
SELECT [FileSizeMB] = CONVERT(NUMERIC(10,2),ROUND(a.size/128.,2)),
       [UsedSpaceMB]= CONVERT(NUMERIC(10,2),ROUND(fileproperty( a.name,'SpaceUsed')/128.,2)) ,
       [UnusedSpaceMB]= CONVERT(NUMERIC(10,2),ROUND((a.size-fileproperty( a.name,'SpaceUsed'))/128.,2)) ,
       [DBFileName]= a.name
FROM sysfiles a

DECLARE @sql varchar(8000)
DECLARE @SizeMB bigint
DECLARE @UsedMB bigint
-- Get current file size in MB
SELECT @SizeMB = size/128. FROM sysfiles where name = @DBFileName
-- Get current space used in MB
SELECT @UsedMB = fileproperty( @DBFileName,'SpaceUsed')/128.0
-- Loop until file at desired size
WHILE  @SizeMB > @UsedMB+@TargetFreeMB+@ShrinkIncrementMB
BEGIN
    SET @sql = 'DBCC SHRINKFILE ( '+@DBFileName+', ' + CONVERT(varchar(20),@SizeMB-@ShrinkIncrementMB)+' ) WITH NO_INFOMSGS'
    PRINT @sql
    PRINT 'Start ' + @sql + ' at ' + CONVERT(varchar(30),getdate(),121)
    EXEC ( @sql )
    PRINT 'Done ' + @sql + ' at '+CONVERT(varchar(30),getdate(),121)
    -- Get current file size in MB
    SELECT @SizeMB = size/128. FROM sysfiles where name = @DBFileName
    -- Get current space used in MB
    SELECT @UsedMB = fileproperty( @DBFileName,'SpaceUsed')/128.0
    PRINT 'SizeMB=' + CONVERT(varchar(20),@SizeMB) + ' UsedMB=' + CONVERT(varchar(20),@UsedMB)
END
--SELECT [EndFileSize] = @SizeMB, [EndUsedSpace] = @UsedMB, [DBFileName] = @DBFileName