/*****
  Performance Section
  (OperationsManager DB):
*/

--Performance insertions per day:
SELECT
  CASE
    WHEN(GROUPING(CONVERT(VARCHAR(20), TimeSampled, 102)) = 1)
    THEN 'All Days'
    ELSE CONVERT(VARCHAR(20), TimeSampled, 102)
    END AS DaySampled,
    COUNT(*) AS PerfInsertPerDay
FROM PerformanceDataAllView WITH (NOLOCK)
GROUP BY CONVERT(VARCHAR(20), TimeSampled, 102) WITH ROLLUP
ORDER BY DaySampled DESC

--Top 20 performance insertions by perf object and counter name:
SELECT TOP 20 pcv.ObjectName,
  pcv.CounterName,
  COUNT (pcv.countername) AS Total
FROM performancedataallview AS pdv, performancecounterview AS pcv
WHERE (pdv.performancesourceinternalid = pcv.performancesourceinternalid)
GROUP BY pcv.objectname, pcv.countername
ORDER BY COUNT (pcv.countername) DESC
 

--To view all performance insertions for a given computer:
SELECT DISTINCT Path,
  ObjectName,
  CounterName,
  InstanceName
FROM PerformanceDataAllView pdv WITH (NOLOCK)
INNER JOIN PerformanceCounterView pcv ON pdv.performancesourceinternalid = pcv.performancesourceinternalid
INNER JOIN BaseManagedEntity bme ON pcv.ManagedEntityId = bme.BaseManagedEntityId
WHERE path = 'sql2a.opsmgr.net'
ORDER BY objectname, countername, InstanceName
 
--To pull all perf data for a given computer, object, counter, and instance:
SELECT Path,
  ObjectName,
  CounterName,
  InstanceName,
  SampleValue,
  TimeSampled
FROM PerformanceDataAllView pdv WITH (NOLOCK)
  INNER JOIN PerformanceCounterView pcv ON pdv.performancesourceinternalid = pcv.performancesourceinternalid
  INNER JOIN BaseManagedEntity bme ON pcv.ManagedEntityId = bme.BaseManagedEntityId
WHERE path = 'sql2a.opsmgr.net' AND
  objectname = 'LogicalDisk' AND
  countername = 'Free Megabytes'
ORDER BY timesampled DESC
