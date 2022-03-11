SET NOCOUNT ON 

DECLARE @SourceDirBackupFiles nvarchar(200)
DECLARE @DestDirDbFiles nvarchar(200)
DECLARE @DestDirLogFiles nvarchar(200)

SET @SourceDirBackupFiles = '\\PATH\TO\REMOTE\BACKUP\SHARE'
SET @DestDirDbFiles = CONVERT(nvarchar,(SELECT serverproperty('InstanceDefaultDataPath')))
SET @DestDirLogFiles = CONVERT(nvarchar, (SELECT serverproperty('InstanceDefaultLogPath'))) 


--Table to hold each backup file name in
CREATE TABLE #files(fname varchar(200),depth int, file_ int)
INSERT #files
EXECUTE master.dbo.xp_dirtree @SourceDirBackupFiles, 1, 1

--Table to hold the result from RESTORE HEADERONLY. Needed to get the database name out from
CREATE TABLE #bdev(
BackupName nvarchar(128) 
,BackupDescription nvarchar(255) 
,BackupType smallint
,ExpirationDate datetime
,Compressed tinyint
,Position smallint
,DeviceType tinyint
,UserName nvarchar(128) 
,ServerName nvarchar(128) 
,DatabaseName nvarchar(128) 
,DatabaseVersion bigint
,DatabaseCreationDate datetime
,BackupSize numeric(20,0)
,FirstLSN numeric(25,0)
,LastLSN numeric(25,0)
,CheckpointLSN numeric(25,0)
,DatabaseBackupLSN numeric(25,0)
,BackupStartDate datetime
,BackupFinishDate datetime
,SortOrder smallint
,[CodePage] smallint
,UnicodeLocaleId bigint
,UnicodeComparisonStyle bigint
,CompatibilityLevel tinyint
,SoftwareVendorId bigint
,SoftwareVersionMajor bigint
,SoftwareVersionMinor bigint
,SoftwareVersionBuild bigint
,MachineName nvarchar(128) 
,Flags bigint
,BindingID uniqueidentifier
,RecoveryForkID uniqueidentifier
,Collation nvarchar(128) 
,FamilyGUID uniqueidentifier
,HasBulkLoggedData bigint
,IsSnapshot bigint
,IsReadOnly bigint
,IsSingleUser bigint
,HasBackupChecksums bigint
,IsDamaged bigint
,BegibsLogChain bigint
,HasIncompleteMetaData bigint
,IsForceOffline bigint
,IsCopyOnly bigint
,FirstRecoveryForkID uniqueidentifier
,ForkPointLSN numeric(25,0)
,RecoveryModel nvarchar(128) 
,DifferentialBaseLSN numeric(25,0)
,DifferentialBaseGUID uniqueidentifier
,BackupTypeDescription nvarchar(128) 
,BackupSetGUID uniqueidentifier
,CompressedBackupSize bigint
,Containment bigint
, KeyAlgorithm nvarchar(32)
, EncryptorThumbprint varbinary(20)
, EncryptorType nvarchar(23)
)

--Table to hold result from RESTORE FILELISTONLY. Need to generate the MOVE options to the RESTORE command
CREATE TABLE #dbfiles(
LogicalName nvarchar(128) 
,PhysicalName nvarchar(260) 
,[Type] char(1) 
,FileGroupName nvarchar(128) 
,Size numeric(20,0)
,MaxSize numeric(20,0)
,FileId bigint
,CreateLSN numeric(25,0)
,DropLSN numeric(25,0)
,UniqueId uniqueidentifier
,ReadOnlyLSN numeric(25,0)
,ReadWriteLSN numeric(25,0)
,BackupSizeInBytes bigint
,SourceBlockSize bigint
,FilegroupId bigint
,LogGroupGUID uniqueidentifier
,DifferentialBaseLSN numeric(25)
,DifferentialBaseGUID uniqueidentifier
,IsReadOnly bigint
,IsPresent int 
,TDEThumbprint uniqueidentifier
)


DECLARE @fname varchar(200) 
DECLARE @dirfile varchar(300) 
DECLARE @LogicalName nvarchar(128) 
DECLARE @PhysicalName nvarchar(260) 
DECLARE @type char(1) 
DECLARE @DbName sysname 
DECLARE @sql nvarchar(1000) 

DECLARE files CURSOR FOR
SELECT fname FROM #files

DECLARE dbfiles CURSOR FOR
SELECT LogicalName, PhysicalName, Type FROM #dbfiles

OPEN files
FETCH NEXT FROM files INTO @fname
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @dirfile = @SourceDirBackupFiles + @fname

    --Get database name from RESTORE HEADERONLY, assumes there's only one backup on each backup file.
    TRUNCATE TABLE #bdev
    INSERT #bdev
    EXEC('RESTORE HEADERONLY FROM DISK = ''' + @dirfile + '''') 
    SET @DbName = (SELECT DatabaseName FROM #bdev)

    --Construct the beginning for the RESTORE DATABASE command
    SET @sql = 'RESTORE DATABASE [' + @DbName + '] FROM DISK = ''' + @dirfile + ''' WITH STATS=10, MOVE '

    --Get information about database files from backup device into temp table
    TRUNCATE TABLE #dbfiles
    INSERT #dbfiles
    EXEC('RESTORE FILELISTONLY FROM DISK = ''' + @dirfile + '''')

    OPEN dbfiles
    FETCH NEXT FROM dbfiles INTO @LogicalName, @PhysicalName, @type
    --For each database file that the database uses
    WHILE @@FETCH_STATUS = 0
        BEGIN
        IF @type = 'D'
            SET @sql = @sql + '''' + @LogicalName + ''' TO ''' + @DestDirDbFiles + @DbName + '.mdf'', MOVE '
        ELSE IF @type = 'L'
            SET @sql = @sql + '''' + @LogicalName + ''' TO ''' + @DestDirLogFiles + @DbName + '_log.ldf'''
        FETCH NEXT FROM dbfiles INTO @LogicalName, @PhysicalName, @type
    END

    --Here's the actual RESTORE command 
    PRINT @sql 
    --Remove the comment below if you want the procedure to actually execute the restore command. 
    --EXEC(@sql) 
    CLOSE dbfiles 
    FETCH NEXT FROM files INTO @fname 
END 

CLOSE files 
DEALLOCATE dbfiles 
DEALLOCATE files 

DROP TABLE #files
DROP TABLE #bdev
DROP TABLE #dbfiles
