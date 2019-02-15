DECLARE @sp_who2 TABLE (
    SPID INT,
    Status VARCHAR(255) NULL,
    Login SYSNAME NULL,
    HostName SYSNAME NULL,
    BlkBy SYSNAME NULL,
    DBName SYSNAME NULL,
    Command VARCHAR(255) NULL,
    CPUTime INT NULL,
    DiskIO INT NULL,
    LastBatch VARCHAR(255) NULL,
    ProgramName VARCHAR(255) NULL,
    SPID2 INT,
    REQUESTID INT 
)
INSERT @sp_who2
EXEC sp_who2

SELECT
    --SPID, BlkBy, HostName, CPUTime, DiskIO, LastBatch 
    q.SPID, q.Status, q.Login, q.HostName, q.BlkBy, q.Command, q.CPUTime, q.DiskIO, q.LastBatch
FROM @sp_who2 q
WHERE DBName = 'HPSMDb'
order by q.LastBatch, q.SPID