/*****
  Operational Database Queries:
  Alerts Section (OperationsManager DB):
*/

--Number of console Alerts per Day:
SELECT CONVERT(VARCHAR(20), TimeAdded, 102) AS DayAdded,
  COUNT(*) AS NumAlertsPerDay
FROM Alert WITH (NOLOCK)
WHERE TimeRaised is not NULL
GROUP BY CONVERT(VARCHAR(20), TimeAdded, 102)
ORDER BY DayAdded DESC

--Top 20 Alerts in an Operational Database, by Alert Count
SELECT TOP 20 SUM(1) AS AlertCount,
  AlertStringName AS 'AlertName',
  AlertStringDescription AS 'Description',
  Name,
  MonitoringRuleId
FROM Alertview WITH (NOLOCK)
WHERE TimeRaised is not NULL
GROUP BY AlertStringName, AlertStringDescription, Name, MonitoringRuleId
ORDER BY AlertCount DESC
 
--Top 20 Alerts in an Operational Database, by Repeat Count
SELECT TOP 20 SUM(RepeatCount+1) AS RepeatCount,
  AlertStringName as 'AlertName',
  AlertStringDescription as 'Description',
  Name,
  MonitoringRuleId
FROM Alertview WITH (NOLOCK)
WHERE Timeraised is not NULL
GROUP BY AlertStringName, AlertStringDescription, Name, MonitoringRuleId
ORDER BY RepeatCount DESC
 
--Top 20 Objects generating the most Alerts in an Operational Database, by Repeat Count
SELECT TOP 20 SUM(RepeatCount+1) AS RepeatCount,
  MonitoringObjectPath AS 'Path'
FROM Alertview WITH (NOLOCK)
WHERE Timeraised is not NULL
GROUP BY MonitoringObjectPath
ORDER BY RepeatCount DESC
 
--Top 20 Objects generating the most Alerts in an Operational Database, by Alert Count
SELECT TOP 20 SUM(1) AS AlertCount,
  MonitoringObjectPath AS 'Path'
FROM Alertview WITH (NOLOCK)
WHERE TimeRaised is not NULL
GROUP BY MonitoringObjectPath
ORDER BY AlertCount DESC
 
--Number of console Alerts per Day by Resolution State:
SELECT
  CASE
    WHEN(GROUPING(CONVERT(VARCHAR(20), TimeAdded, 102)) = 1)
    THEN 'All Days'
    ELSE CONVERT(VARCHAR(20), TimeAdded, 102)
  END AS [Date],
  CASE
    WHEN(GROUPING(ResolutionState) = 1)
    THEN 'All Resolution States'
    ELSE CAST(ResolutionState AS VARCHAR(5))
  END AS [ResolutionState],
  COUNT(*) AS NumAlerts
FROM Alert WITH (NOLOCK)
