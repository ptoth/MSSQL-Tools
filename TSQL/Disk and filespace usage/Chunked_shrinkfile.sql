/*
This script is used to shrink a database file in
increments until it reaches a target free space limit.
Run this script in the database with the file to be shrunk.
1. Set @DBFileName to the name of database file to shrink.
2. Set @TargetFreeMB to the desired file free space in MB after shrink.
3. Set @ShrinkIncrementMB to the increment to shrink file by in MB
4. Run the script
*/
set nocount on
declare @DBFileName sysname
declare @TargetFreeMB int
declare @ShrinkIncrementMB int
-- Set Name of Database file to shrink
set @DBFileName = '<DATABASE_NAME>'
-- Set Desired file free space in MB after shrink
set @TargetFreeMB = 102400
-- Set Increment to shrink file by in MB
set @ShrinkIncrementMB = 1024
-- Show Size, Space Used, Unused Space, and Name of all database files
select [FileSizeMB] = convert(numeric(10,2),round(a.size/128.,2)),
       [UsedSpaceMB]= convert(numeric(10,2),round(fileproperty( a.name,'SpaceUsed')/128.,2)) ,
       [UnusedSpaceMB]= convert(numeric(10,2),round((a.size-fileproperty( a.name,'SpaceUsed'))/128.,2)) ,
       [DBFileName]= a.name
from sysfiles a

declare @sql varchar(8000)
declare @SizeMB bigint
declare @UsedMB bigint
-- Get current file size in MB
select @SizeMB = size/128. from sysfiles where name = @DBFileName
-- Get current space used in MB
select @UsedMB = fileproperty( @DBFileName,'SpaceUsed')/128.0
-- Loop until file at desired size
while  @SizeMB > @UsedMB+@TargetFreeMB+@ShrinkIncrementMB
begin
 set @sql = 'dbcc shrinkfile ( '+@DBFileName+', ' + convert(varchar(20),@SizeMB-@ShrinkIncrementMB)+' ) WITH NO_INFOMSGS'
 print @sql
 print 'Start ' + @sql + ' at ' + convert(varchar(30),getdate(),121)
 exec ( @sql )
 print 'Done ' + @sql + ' at '+convert(varchar(30),getdate(),121)
 -- Get current file size in MB
 select @SizeMB = size/128. from sysfiles where name = @DBFileName
 -- Get current space used in MB
 select @UsedMB = fileproperty( @DBFileName,'SpaceUsed')/128.0
 print 'SizeMB=' + convert(varchar(20),@SizeMB) + ' UsedMB=' + convert(varchar(20),@UsedMB)
end
--select [EndFileSize] = @SizeMB, [EndUsedSpace] = @UsedMB, [DBFileName] = @DBFileName
