SELECT
   DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), CURRENT_TIMESTAMP), 
   DeadlockEventXML.value('(event/@timestamp)[1]', 'datetime2')) AS [EventTime],
   DeadlockEventXML.value('(//process[@id[//victim-list/victimProcess[1]/@id]]/@hostname)[1]', 'nvarchar(max)') AS HostName,
   DeadlockEventXML.value('(//process[@id[//victim-list/victimProcess[1]/@id]]/@clientapp)[1]', 'nvarchar(max)') AS ClientApp,
   DB_NAME(DeadlockEventXML.value('(//process[@id[//victim-list/victimProcess[1]/@id]]/@currentdb)[1]', 'nvarchar(max)')) AS [DatabaseName],
   DeadlockEventXML.value('(//process[@id[//victim-list/victimProcess[1]/@id]]/@transactionname)[1]', 'nvarchar(max)') AS VictimTransactionName,
   DeadlockEventXML.value('(//process[@id[//victim-list/victimProcess[1]/@id]]/@isolationlevel)[1]', 'nvarchar(max)') AS IsolationLevel,
   DeadlockEventXML.query('(event/data[@name="xml_report"]/value/deadlock)[1]') AS DeadLockGraph,
   DeadlockEventXML
FROM
(
   SELECT 
      XEvent.query('.') AS DeadlockEventXML,
     Data.TargetData
   FROM 
   (
      SELECT 
        CAST(target_data AS XML) AS TargetData
        FROM sys.dm_xe_session_targets st
        JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address
        WHERE s.name = 'system_health' AND
          st.target_name = 'ring_buffer'
   ) AS Data
   CROSS APPLY TargetData.nodes('RingBufferTarget/event[@name="xml_deadlock_report"]') AS XEventData(XEvent)
) AS DeadlockInfo

