DECLARE @LockTable TABLE
(
    SPID INT
    ,[Status] varchar( 100 )
    ,[Login] varchar( 100 )
    ,HostName varchar(100 )
    ,BlkBy VARCHAR( 100 )
    ,DBName varchar( 100 )
    ,Command varchar( 100 )
    ,CPUTime BIGINT
    ,DiskIO BIGINT
    ,LastBatch varchar( 100 )
    ,ProgramName VARCHAR( 100 )
    ,SPID2 INT
    ,REQUESTID INT
    ,BlockOrder INT
)

INSERT INTO @LockTable
    ( SPID
    , [Status]
    , [Login]
    , HostName
    , BlkBy
    , DBName
    , Command
    , CPUTime
    , DiskIO
    , LastBatch
    , ProgramName
    , SPID2
    , REQUESTID
    )
EXEC sp_who2

UPDATE @LockTable
SET BlockOrder = 0, BlkBy = 0
WHERE BlkBy = '  .'

UPDATE @LockTable
SET BlockOrder = '1'
FROM @LockTable L
WHERE BlkBy = '0'
    AND EXISTS
    (
        SELECT 1
        FROM @LockTable L1
        WHERE CAST( L1.BlkBy AS INT ) = L.SPID
    )

SELECT BlockOrder
    , SPID
    , [Status]
    , [Login]
    , HostName
    , BlkBy
    , DBName
    , Command
    , CPUTime
    , DiskIO
    , LastBatch
    , ProgramName
    , SPID2
    , REQUESTID
FROM @LockTable
WHERE
    BlockOrder = 1
ORDER BY Blockorder DESC

SELECT
    BlockOrder
    , SPID
    , [Status]
    , [Login]
    , HostName
    , BlkBy
    , DBName
    , Command
    , CPUTime
    , DiskIO
    , LastBatch
    , ProgramName
    , SPID2
    , REQUESTID
FROM @LockTable
ORDER BY ISNULL( BlockOrder, 0 ) DESC, CAST( BlkBy AS INT )DESC
