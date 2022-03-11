/*Create temporary table to hold the values */
IF OBJECT_ID('TEMPDB.dbo.#Logshipping_Monitor') IS NOT NULL
    DROP TABLE #Logshipping_Monitor
 
CREATE TABLE #Logshipping_Monitor
(    Primary_Server        nvarchar(100),
    Primary_Database    nvarchar(100),
    Secondary_Server    nvarchar(100),
    Secondary_Database    nvarchar(100),
    Restore_Latency        int,
    Min_Behind_Primary    int
)
 
/* Insert temp table with values */
INSERT INTO #Logshipping_Monitor
SELECT    secondary_server, secondary_database, primary_server, primary_database, 
        last_restored_latency,  DATEDIFF(minute, last_restored_date_utc, GETUTCDATE()) + 
                last_restored_latency [Minutes Behind Current Time]
FROM    msdb.dbo.log_shipping_monitor_secondary 
ORDER BY [Minutes Behind Current Time] desc
 
select * from #Logshipping_Monitor
DROP TABLE #Logshipping_Monitor