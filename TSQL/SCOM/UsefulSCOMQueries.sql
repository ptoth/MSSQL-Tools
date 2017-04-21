--Simple query to display large tables, to determine what is taking up space in the database:

SELECT so.NAME,
    8 * Sum(CASE WHEN si.indid IN (0, 1) THEN si.reserved END) AS data_kb,
    COALESCE(8 * Sum(CASE WHEN si.indid NOT IN (0, 1, 255) THEN si.reserved END), 0) AS index_kb,
    COALESCE(8 * Sum(CASE WHEN si.indid IN (255) THEN si.reserved END), 0) AS blob_kb
FROM dbo.sysobjects AS so JOIN dbo.sysindexes AS si ON (si.id = so.id)
WHERE 'U' = so.type GROUP BY so.NAME ORDER BY data_kb DESC

--Database Size and used space:
SELECT a.fileid,
    [FILE_SIZE_MB] = CONVERT(DECIMAL(12,2),Round(a.size/128.000,2)),
    [SPACE_USED_MB] = CONVERT(DECIMAL(12,2),Round(Fileproperty(a.NAME,'SpaceUsed')/128.000,2)),
    [FREE_SPACE_MB] = CONVERT(DECIMAL(12,2),Round((a.size-Fileproperty(a.NAME,'SpaceUsed'))/128.000,2)) ,
    [GROWTH_MB] = CONVERT(DECIMAL(12,2),Round(a.growth/128.000,2)),
    NAME = LEFT(a.NAME,15),
    FILENAME = LEFT(a.filename,60)
FROM dbo.sysfiles a

--Number of console Alerts per Day:
SELECT CONVERT(VARCHAR(20), timeadded, 102) AS DayAdded, Count(*) AS NumAlertsPerDay
FROM alert WITH (NOLOCK)
WHERE timeraised IS NOT NULL
GROUP BY CONVERT(VARCHAR(20), timeadded, 102)
ORDER BY dayadded DESC

--Top 20 Alerts in an Operational Database, by Alert Count
SELECT TOP 20 Sum(1) AS AlertCount,
    alertstringname,
    alertstringdescription,
    monitoringruleid,
    NAME
FROM alertview WITH (NOLOCK)
WHERE timeraised IS NOT NULL
GROUP BY alertstringname, alertstringdescription, monitoringruleid, NAME
ORDER BY alertcount DESC

--Top 20 Alerts in an Operational Database, by Repeat Count
SELECT TOP 20 Sum(repeatcount+1) AS RepeatCount,
    alertstringname,
    alertstringdescription,
    monitoringruleid,
    NAME
FROM alertview WITH (NOLOCK)
WHERE timeraised IS NOT NULL
GROUP BY alertstringname, alertstringdescription, monitoringruleid, NAME
ORDER BY repeatcount DESC

--Events per day:
SELECT
    CASE
        WHEN(Grouping(CONVERT(VARCHAR(20), timeadded, 102)) = 1)
        THEN 'All Days'
        ELSE CONVERT(VARCHAR(20), timeadded, 102)
    END AS DayAdded,
    Count(*) AS EventsPerDay
FROM eventallview
GROUP BY CONVERT(VARCHAR(20), timeadded, 102) WITH ROLLUP
ORDER BY dayadded DESC

--Most Common Events by event number:
SELECT TOP 20 number AS EventID, Count(*) AS TotalEvents
    FROM eventview WITH (NOLOCK)
GROUP BY number
ORDER BY totalevents DESC

--Performance insertions per day:
SELECT
    CASE WHEN(Grouping(CONVERT(VARCHAR(20), timesampled, 102)) = 1)
        THEN 'All Days'
        ELSE CONVERT(VARCHAR(20), timesampled, 102)
    END AS DaySampled,
    Count(*) AS PerfInsertPerDay
FROM performancedataallview WITH (NOLOCK)
GROUP BY CONVERT(VARCHAR(20), timesampled, 102) WITH ROLLUP
ORDER BY daysampled DESC

--Top 20 performance insertions by perf object and counter name:
SELECT TOP 20 pcv.objectname,
    pcv.countername,
    Count (pcv.countername) AS Total
FROM performancedataallview AS pdv, performancecounterview AS pcv
WHERE (pdv.performancesourceinternalid = pcv.performancesourceinternalid)
GROUP BY pcv.objectname, pcv.countername
ORDER BY Count (pcv.countername) DESC

--State changes per day:
SELECT
    CASE WHEN(Grouping(CONVERT(VARCHAR(20), timegenerated, 102)) = 1)
        THEN 'All Days'
        ELSE CONVERT(VARCHAR(20), timegenerated, 102)
    END AS DayGenerated,
    Count(*) AS StateChangesPerDay
FROM statechangeevent WITH (NOLOCK)
GROUP BY CONVERT(VARCHAR(20), timegenerated, 102) WITH ROLLUP
ORDER BY daygenerated DESC

--Noisiest monitors changing state in the database in the last 7 days:
SELECT DISTINCT TOP 50 Count(sce.stateid) AS NumStateChanges,
    m.displayname AS MonitorDisplayName,
    m.NAME AS MonitorIdName,
    mt.typename AS TargetClass
FROM statechangeevent sce WITH (NOLOCK)
    JOIN state s WITH (NOLOCK) ON sce.stateid = s.stateid
    JOIN monitorview m WITH (NOLOCK) ON s.monitorid = m.id
    JOIN managedtype mt WITH (NOLOCK) ON m.targetmonitoringclassid = mt.managedtypeid
WHERE m.isunitmonitor = 1 -- Scoped to within last 7 days
    AND sce.timegenerated > Dateadd(dd,-7,Getutcdate())
GROUP BY m.displayname, m.NAME,mt.typename
ORDER BY numstatechanges DESC

--Noisiest Monitor in the database – PER Object/Computer in the last 7 days:
SELECT DISTINCT TOP 50 Count(sce.stateid) AS NumStateChanges,
    bme.displayname AS ObjectName,
    bme.path,
    m.displayname AS MonitorDisplayName,
    m.NAME AS MonitorIdName,
    mt.typename AS TargetClass
FROM statechangeevent sce WITH (NOLOCK)
    JOIN state s WITH (NOLOCK) ON sce.stateid = s.stateid
    JOIN basemanagedentity bme WITH (NOLOCK) ON s.basemanagedentityid = bme.basemanagedentityid
    JOIN monitorview m WITH (NOLOCK) ON s.monitorid = m.id
    JOIN managedtype mt WITH (NOLOCK) ON m.targetmonitoringclassid = mt.managedtypeid
WHERE m.isunitmonitor = 1
-- Scoped to specific Monitor (remove the "--" below):
-- AND m.MonitorName like ('%HealthService%')
-- Scoped to specific Computer (remove the "--" below):
-- AND bme.Path like ('%sql%')
-- Scoped to within last 7 days
AND sce.timegenerated > Dateadd(dd,-7,Getutcdate())
GROUP BY s.basemanagedentityid,bme.displayname,bme.path,m.displayname,m.NAME,mt.typename
ORDER BY numstatechanges DESC

--To find the rules collecting the most Performance Signature data in the database:
SELECT managementpack.mpname,
    ruleview.displayname,
    Count(*) AS TotalPerfSig
FROM performancesignaturedata WITH (NOLOCK)
    INNER JOIN performancesignaturehistory WITH (NOLOCK)
        ON performancesignaturedata.performancesignaturehistoryid = performancesignaturehistory.performancesignaturehistoryid
    INNER JOIN performancesignature WITH (NOLOCK)
        ON performancesignaturehistory.performancesignatureid = performancesignature.performancesignatureid
    INNER JOIN ruleview WITH (NOLOCK)
        ON ruleview.id = performancesignature.learningruleid
    INNER JOIN managementpack WITH(NOLOCK)
        ON ruleview.managementpackid = managementpack.managementpackid
GROUP BY managementpack.mpname, ruleview.displayname
ORDER BY totalperfsig DESC, managementpack.mpname, ruleview.displayname

--To find all Performance Signature Collection rules:
SELECT managementpack.mpname,
    rules.rulename
FROM performancesignature WITH (NOLOCK)
    INNER JOIN rules WITH (NOLOCK)
        ON rules.ruleid = performancesignature.learningruleid
    INNER JOIN managementpack WITH (NOLOCK)
        ON rules.managementpackid = managementpack.managementpackid
GROUP BY managementpack.mpname, rules.rulename
ORDER BY managementpack.mpname, rules.rulename
