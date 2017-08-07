/*****
FROM: https://blogs.technet.microsoft.com/kevinholman/2016/11/11/scom-sql-queries/
*/

/*****
  SCOM SQL queries
*/

--Large Table query.  I am putting this at the top, because I use it so much to find out what is taking up so much space in the OpsDB or DW
SELECT TOP 1000
  a2.name AS [tablename], (a1.reserved + ISNULL(a4.reserved,0))* 8 AS reserved,
  a1.rows as row_count, a1.data * 8 AS data,
  (CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8 AS index_size,
  (CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8 AS unused,
  (row_number() over(ORDER BY(a1.reserved + ISNULL(a4.reserved,0)) desc))%2 as l1,
  a3.name AS [schemaname]
FROM (SELECT ps.object_id, SUM (CASE WHEN (ps.index_id < 2) THEN row_count ELSE 0 END) AS [rows],
  SUM (ps.reserved_page_count) AS reserved,
  SUM (CASE
    WHEN (ps.index_id < 2)
      THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
      ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count)
    END ) AS data,
  SUM (ps.used_page_count) AS used
FROM sys.dm_db_partition_stats ps
GROUP BY ps.object_id) AS a1
  LEFT OUTER JOIN (
    SELECT it.parent_id,
      SUM(ps.reserved_page_count) AS reserved,
      SUM(ps.used_page_count) AS used
    FROM sys.dm_db_partition_stats ps
      INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id)
    WHERE it.internal_type IN (202,204)
    GROUP BY it.parent_id) AS a4 ON (a4.parent_id = a1.object_id)
      INNER JOIN sys.all_objects a2  ON ( a1.object_id = a2.object_id )
      INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
WHERE a2.type <> N'S' and a2.type <> N'IT'
 
--Database Size and used space.
--this will show the DB and log file size plus the used/free space in each

SELECT a.FILEID,
  [FILE_SIZE_MB]=convert(decimal(12,2),round(a.size/128.000,2)),
  [SPACE_USED_MB]=convert(decimal(12,2),round(fileproperty(a.name,'SpaceUsed')/128.000,2)),
  [FREE_SPACE_MB]=convert(decimal(12,2),round((a.size-fileproperty(a.name,'SpaceUsed'))/128.000,2)) ,
  [GROWTH_MB]=convert(decimal(12,2),round(a.growth/128.000,2)),
  NAME=left(a.NAME,15),
  FILENAME=left(a.FILENAME,60)
FROM dbo.sysfiles a



/*****
  Alerts Section
  (Warehouse):
*/

--To get all raw alert data from the data warehouse to build reports from:
SELECT *
FROM alert.valertresolutionstate ars
INNER JOIN alert.valertdetail adt ON ars.alertguid = adt.alertguid
INNER JOIN alert.valert alt ON ars.alertguid = alt.alertguid

--To view data on all alerts modified by a specific user:
SELECT ars.alertguid,
  alertname,
  alertdescription,
  statesetbyuserid,
  resolutionstate,
  statesetdatetime,
  severity,
  priority,
  managedentityrowid,
  repeatcount
FROM alert.valertresolutionstate ars
  INNER JOIN alert.valert alt ON ars.alertguid = alt.alertguid
WHERE statesetbyuserid LIKE '%username%'
ORDER BY statesetdatetime

--To view a count of all alerts closed by all users:
SELECT statesetbyuserid,
  Count(*) AS 'Number of Alerts'
FROM alert.valertresolutionstate ars
WHERE resolutionstate = '255'
GROUP BY statesetbyuserid
ORDER BY 'Number of Alerts' DESC

/*****
  events section
  (warehouse):
*/

--To inspect total events in DW, and then break it down per day:
--(this helps us know what we will be grooming out, and look for partitcular day event storms)
SELECT
  CASE
    WHEN(Grouping(CONVERT(VARCHAR(20), datetime, 101)) = 1)
    THEN 'All Days'
    ELSE CONVERT(VARCHAR(20), datetime, 101)
  END AS DayAdded,
  Count(*) AS NumEventsPerDay
FROM event.vevent
GROUP BY CONVERT(VARCHAR(20), datetime, 101) WITH rollup
ORDER BY dayadded DESC

--Most Common Events by event number:
--(This helps us know which event ID’s are the most common in the database)
SELECT TOP 50 eventdisplaynumber, Count(*) AS 'TotalEvents'
FROM event.vevent
GROUP BY eventdisplaynumber
ORDER BY totalevents DESC

--Most common events by event number and raw event description
--(this will take a very long time to run but it shows us not only event ID –
--but a description of the event to help understand which MP is the generating the noise)
SELECT TOP 50 eventdisplaynumber,
  rawdescription,
  Count(*) AS TotalEvents
FROM event.vevent evt
  INNER JOIN event.veventdetail evtd ON evt.eventoriginid = evtd.eventoriginid
GROUP BY eventdisplaynumber, rawdescription
ORDER BY totalevents DESC

--To view all event data in the DW for a given Event ID:
SELECT *
FROM event.vevent ev
  INNER JOIN event.veventdetail evd ON ev.eventoriginid = evd.eventoriginid
  INNER JOIN event.veventparameter evp ON ev.eventoriginid = evp.eventoriginid
WHERE eventdisplaynumber = '6022'

/*****
  performance section
  (warehouse):
*/

--Raw data – core query:
SELECT TOP 10 *
FROM perf.vperfraw pvpr
  INNER JOIN vmanagedentity vme ON pvpr.managedentityrowid = vme.managedentityrowid
  INNER JOIN vperformanceruleinstance vpri ON pvpr.performanceruleinstancerowid = vpri.performanceruleinstancerowid
  INNER JOIN vperformancerule vpr ON vpr.rulerowid = vpri.rulerowid

--Raw data – More selective of “interesting” output data:
SELECT TOP 10 path,
  fullname,
  objectname,
  countername,
  instancename,
  samplevalue,
  datetime
FROM perf.vperfraw pvpr
  INNER JOIN vmanagedentity vme ON pvpr.managedentityrowid = vme.managedentityrowid
  INNER JOIN vperformanceruleinstance vpri ON pvpr.performanceruleinstancerowid = vpri.performanceruleinstancerowid
  INNER JOIN vperformancerule vpr ON vpr.rulerowid = vpri.rulerowid

--Raw data – Scoped to a ComputerName (FQDN)
SELECT TOP 10 path,
  fullname,
  objectname,
  countername,
  instancename,
  samplevalue,
  datetime
FROM perf.vperfraw pvpr
  INNER JOIN vmanagedentity vme ON pvpr.managedentityrowid = vme.managedentityrowid
  INNER JOIN vperformanceruleinstance vpri ON pvpr.performanceruleinstancerowid = vpri.performanceruleinstancerowid
  INNER JOIN vperformancerule vpr ON vpr.rulerowid = vpri.rulerowid
WHERE path = 'sql2a.opsmgr.net'

--Raw data – Scoped to a Counter:
SELECT TOP 10 path,
  fullname,
  objectname,
  countername,
  instancename,
  samplevalue,
  datetime
FROM perf.vperfraw pvpr
  INNER JOIN vmanagedentity vme ON pvpr.managedentityrowid = vme.managedentityrowid
  INNER JOIN vperformanceruleinstance vpri ON pvpr.performanceruleinstancerowid = vpri.performanceruleinstancerowid
  INNER JOIN vperformancerule vpr ON vpr.rulerowid = vpri.rulerowid
WHERE countername = 'Private Bytes'

--Raw data – Scoped to a Computer and Counter:
SELECT TOP 10 path,
  fullname,
  objectname,
  countername,
  instancename,
  samplevalue,
  datetime
FROM perf.vperfraw pvpr
  INNER JOIN vmanagedentity vme ON pvpr.managedentityrowid = vme.managedentityrowid
  INNER JOIN vperformanceruleinstance vpri ON pvpr.performanceruleinstancerowid = vpri.performanceruleinstancerowid
  INNER JOIN vperformancerule vpr ON vpr.rulerowid = vpri.rulerowid
WHERE countername = 'Private Bytes'
  AND path LIKE '%op%'

--Raw data – How to get all the possible optional data to modify these queries above, in a list:
SELECT DISTINCT path
FROM perf.vperfraw pvpr
  INNER JOIN vmanagedentity vme ON pvpr.managedentityrowid = vme.managedentityrowid
  INNER JOIN vperformanceruleinstance vpri ON pvpr.performanceruleinstancerowid = vpri.performanceruleinstancerowid
  INNER JOIN vperformancerule vpr ON vpr.rulerowid = vpri.rulerowidSELECT DISTINCT fullname
FROM perf.vperfraw pvpr
  INNER JOIN vmanagedentity vme ON pvpr.managedentityrowid = vme.managedentityrowid
  INNER JOIN vperformanceruleinstance vpri ON pvpr.performanceruleinstancerowid = vpri.performanceruleinstancerowid
  INNER JOIN vperformancerule vpr ON vpr.rulerowid = vpri.rulerowidSELECT DISTINCT objectname
FROM perf.vperfraw pvpr
  INNER JOIN vmanagedentity vme ON pvpr.managedentityrowid = vme.managedentityrowid
  INNER JOIN vperformanceruleinstance vpri ON pvpr.performanceruleinstancerowid = vpri.performanceruleinstancerowid
  INNER JOIN vperformancerule vpr ON vpr.rulerowid = vpri.rulerowidSELECT DISTINCT countername
FROM perf.vperfraw pvpr
  INNER JOIN vmanagedentity vme ON pvpr.managedentityrowid = vme.managedentityrowid
  INNER JOIN vperformanceruleinstance vpri ON pvpr.performanceruleinstancerowid = vpri.performanceruleinstancerowid
  INNER JOIN vperformancerule vpr ON vpr.rulerowid = vpri.rulerowidSELECT DISTINCT instancename
FROM perf.vperfraw pvpr
  INNER JOIN vmanagedentity vme ON pvpr.managedentityrowid = vme.managedentityrowid
  INNER JOIN vperformanceruleinstance vpri ON pvpr.performanceruleinstancerowid = vpri.performanceruleinstancerowid
  INNER JOIN vperformancerule vpr ON vpr.rulerowid = vpri.rulerowid

--Here is how to access ManagedEntity (ME) data in the DW:
SELECT * FROM vmanagedentity

--How to get members of a group:
SELECT vme.path,
  vme.displayname
FROM vmanagedentity vme
  JOIN vrelationship vr ON vr.targetmanagedentityrowid = vme.managedentityrowid
  JOIN vmanagedentity vme2 ON vme2.managedentityrowid = vr.sourcemanagedentityrowid
WHERE vme2.displayname = 'All Windows Computers'

--Here is an example pulling perf for a specific managed entity:
SELECT
  vph.datetime,
  vph.samplecount,
  vph.averagevalue,
  vph.minvalue,
  vph.maxvalue,
  vph.standarddeviation,
  vperformanceruleinstance.instancename,
  vmanagedentity.path,
  vperformancerule.objectname,
  vperformancerule.countername
FROM perf.vperfhourly AS vph
  INNER JOIN  vperformanceruleinstance ON vperformanceruleinstance.performanceruleinstancerowid = vph.performanceruleinstancerowid
  INNER JOIN  vmanagedentity ON vph.managedentityrowid = vmanagedentity.managedentityrowid
  INNER JOIN  vperformancerule ON vperformanceruleinstance.rulerowid = vperformancerule.rulerowid
WHERE vperformancerule.objectname = 'LogicalDisk'
  AND vperformancerule.countername IN ('% Free Space')
  AND vmanagedentity.path = 'DC01.opsmgr.net'

--Or similar:
--Given one machine and one set of Perf counters, get the sampled values
SELECT pr.objectname,
  pr.countername,
  pri.instancename,
  p.samplevalue,
  p.datetime
FROM perf.vperfraw p
  INNER JOIN vmanagedentity me ON me.managedentityrowid = p.managedentityrowid
  INNER JOIN vmanagedentity tlh ON tlh.managedentityrowid = me.toplevelhostmanagedentityrowid
  INNER JOIN vperformanceruleinstance pri ON pri.performanceruleinstancerowid = p.performanceruleinstancerowid
  INNER JOIN vperformancerule pr ON pr.rulerowid = pri.rulerowid
WHERE tlh.displayname = 'dc01.opsmgr.net'
  AND pr.objectname = 'Processor'
  AND pr.countername = '% Processor Time'
  AND pri.instancename = '_Total'
ORDER BY p.datetime

--Given a machine, what Object / Counters / Instances are there for all of its Managed Entities?
SELECT pr.objectname,
  pr.countername,
  pri.instancename,
  Count(*) AS NumSamples
  --, p.SampleValue
FROM perf.vperfraw p
  INNER JOIN vmanagedentity me ON me.managedentityrowid = p.managedentityrowid
  INNER JOIN vmanagedentity tlh ON tlh.managedentityrowid = me.toplevelhostmanagedentityrowid
  INNER JOIN vperformanceruleinstance pri ON pri.performanceruleinstancerowid = p.performanceruleinstancerowid
  INNER JOIN vperformancerule pr ON pr.rulerowid = pri.rulerowid
WHERE tlh.displayname = 'dc01.opsmgr.net'
GROUP BY pr.objectname, pr.countername, pri.instancename

--Get list of groups
SELECT DISTINCT displayname,
  managedentityrowid
FROM vmanagedentity
  INNER JOIN vrelationship ON vmanagedentity.managedentityrowid=vrelationship.sourcemanagedentityrowid
  INNER JOIN vrelationshiptype ON vrelationship.relationshiptyperowid=vrelationshiptype.relationshiptyperowid
  INNER JOIN vrelationshipmanagementgroup ON vrelationshipmanagementgroup.relationshiprowid=vrelationship.relationshiprowid
WHERE (vrelationshiptype.relationshiptypesystemname='Microsoft.SystemCenter.ComputerGroupContainsComputer'
  OR vrelationshiptype.relationshiptypesystemname LIKE '%InstanceGroup%')
  AND vrelationshipmanagementgroup.todatetime IS NULL
ORDER BY displayname ASC

--Get ID for a specific group
SELECT DISTINCT managedentityrowid
FROM vmanagedentity
  INNER JOIN vrelationship ON vmanagedentity.managedentityrowid=vrelationship.sourcemanagedentityrowid
  INNER JOIN vrelationshiptype ON vrelationship.relationshiptyperowid=vrelationshiptype.relationshiptyperowid
  INNER JOIN vrelationshipmanagementgroup ON vrelationshipmanagementgroup.relationshiprowid=vrelationship.relationshiprowid
WHERE (vrelationshiptype.relationshiptypesystemname='Microsoft.SystemCenter.ComputerGroupContainsComputer'
  OR vrelationshiptype.relationshiptypesystemname LIKE '%InstanceGroup%')
  AND displayname='All Computers'
  AND vrelationshipmanagementgroup.todatetime IS NULL

--Get list of groups with ManagementGroup Row ID
SELECT DISTINCT displayname,
  managedentityrowid,
  mg.managementgrouprowid
FROM vmanagedentity
  INNER JOIN vrelationship ON vmanagedentity.managedentityrowid=vrelationship.sourcemanagedentityrowid
  INNER JOIN vrelationshiptype ON vrelationship.relationshiptyperowid=vrelationshiptype.relationshiptyperowid
  INNER JOIN vrelationshipmanagementgroup ON vrelationshipmanagementgroup.relationshiprowid=vrelationship.relationshiprowid
  JOIN vmanagementgroup mg ON mg.managementgrouprowid=vmanagedentity.managementgrouprowid
WHERE (vrelationshiptype.relationshiptypesystemname='Microsoft.SystemCenter.ComputerGroupContainsComputer'
  OR vrelationshiptype.relationshiptypesystemname LIKE '%InstanceGroup%')
  AND vrelationshipmanagementgroup.todatetime IS NULL
ORDER BY displayname ASC

--Get list of objects in a group (pass ManagedEntityRowId for the group as a parameter)
SELECT DISTINCT vme2.managedentityrowid,
  DisplayName = vme2.displayname
FROM vrelationship r
  INNER JOIN vmanagedentity vme ON vme.managedentityrowid=r.targetmanagedentityrowid
  INNER JOIN vmanagedentity vme2 ON vme.toplevelhostmanagedentityrowid=vme2.managedentityrowid
  INNER JOIN vrelationshipmanagementgroup rmg ON rmg.relationshiprowid=r.relationshiprowid
WHERE sourcemanagedentityrowid = @group
  AND rmg.todatetime IS NULL
ORDER BY vme2.displayname

--Finally – here is an example pulling it all together:
SELECT * FROM perf.vperfdaily vpd
  INNER JOIN vperformanceruleinstance vpri ON vpri.performanceruleinstancerowid = vpd.performanceruleinstancerowid
  INNER JOIN vperformancerule vpr ON vpri.rulerowid = vpr.rulerowid
  INNER JOIN vmanagedentity vme ON vme.managedentityrowid = vpd.managedentityrowid
WHERE vpr.objectname = 'LogicalDisk'
  AND vpr.countername IN ('% Free Space')
  AND vpd.datetime > '3/6/2016'
  AND vme.toplevelhostmanagedentityrowid IN
    (
    --Get list of objects in a group (pass ManagedEntityRowId for the group as a parameter)
    SELECT DISTINCT vme2.managedentityrowid
    --,DisplayName = vme2.displayname
    FROM vrelationship r
    INNER JOIN vmanagedentity vme ON vme.managedentityrowid=r.targetmanagedentityrowid
    INNER JOIN vmanagedentity vme2 ON vme.toplevelhostmanagedentityrowid=vme2.managedentityrowid
    INNER JOIN vrelationshipmanagementgroup rmg ON rmg.relationshiprowid=r.relationshiprowid
    WHERE sourcemanagedentityrowid=
    (
    --Get ID for a specific group
    SELECT DISTINCT managedentityrowid
    FROM vmanagedentity
      INNER JOIN vrelationship ON vmanagedentity.managedentityrowid=vrelationship.sourcemanagedentityrowid
      INNER JOIN vrelationshiptype ON vrelationship.relationshiptyperowid=vrelationshiptype.relationshiptyperowid
      INNER JOIN vrelationshipmanagementgroup ON vrelationshipmanagementgroup.relationshiprowid=vrelationship.relationshiprowid
    WHERE (vrelationshiptype.relationshiptypesystemname='Microsoft.SystemCenter.ComputerGroupContainsComputer'
      OR vrelationshiptype.relationshiptypesystemname LIKE '%InstanceGroup%')
      AND displayname='Operations Manager Management Server Computer Group'
      AND vrelationshipmanagementgroup.todatetime IS NULL
    )
    AND rmg.todatetime IS NULL
    )

-- grooming IN the DATAWAREHOUSE:
--Here is a view of the current data retention in your data warehouse:
SELECT ds.datasetdefaultname AS 'Dataset Name',
  sda.aggregationtypeid AS 'Agg Type 0=raw, 20=Hourly, 30=Daily',
  sda.maxdataagedays AS 'Retention Time in Days'
FROM dataset ds, standarddatasetaggregation sda
WHERE ds.datasetid = sda.datasetid
ORDER BY ds.datasetdefaultname

--To view the number of days of total data of each type in the DW:
SELECT Datediff(d, Min(dwcreateddatetime), Getdate()) AS [Current]
FROM alert.valert

SELECT Datediff(d, Min(datetime), Getdate()) AS [Current]
FROM event.vevent

SELECT Datediff(d, Min(datetime), Getdate()) AS [Current]
FROM perf.vperfraw

SELECT Datediff(d, Min(datetime), Getdate()) AS [Current]
FROM perf.vperfhourly

SELECT Datediff(d, Min(datetime), Getdate()) AS [Current]
FROM perf.vperfdaily

SELECT Datediff(d, Min(datetime), Getdate()) AS [Current]
FROM state.vstateraw

SELECT Datediff(d, Min(datetime), Getdate()) AS [Current]
FROM state.vstatehourly

SELECT Datediff(d, Min(datetime), Getdate()) AS [Current]
FROM state.vstatedaily

--To view the oldest and newest recorded timestamps of each data type in the DW:
SELECT Min(datetime) FROM event.vevent
SELECT Max(datetime) FROM event.vevent
SELECT Min(datetime) FROM perf.vperfraw
SELECT Max(datetime) FROM perf.vperfraw
SELECT Min(dwcreateddatetime) FROM alert.valert
SELECT Max(dwcreateddatetime) FROM alert.valert

--Default query to return all RAW AEM data:
SELECT * FROM [CM].[vcmaemraw] Rw
  INNER JOIN dbo.aemcomputer Computer ON Computer.aemcomputerrowid = Rw.aemcomputerrowid
  INNER JOIN dbo.aemuser Usr ON Usr.aemuserrowid = Rw.aemuserrowid
  INNER JOIN dbo.aemerrorgroup EGrp ON Egrp.errorgrouprowid = Rw.errorgrouprowid
  INNER JOIN dbo.aemapplication App ON App.applicationrowid = Egrp.applicationrowid

--Count the raw crashes per day:
SELECT CONVERT(CHAR(10), datetime, 101) AS "Crash Date (by Day)",
  Count(*) AS "Number of Crashes"
FROM [CM].[vcmaemraw]
GROUP BY CONVERT(CHAR(10), datetime, 101)
ORDER BY "crash date (by day)" DESC

--Count the total number of raw crashes in the DW database:
SELECT Count(*) FROM cm.vcmaemraw

--Default grooming for the DW for the AEM dataset:
--(Aggregated data kept for 400 days, RAW 30 days by default)
SELECT aggregationtypeid,
  buildaggregationstoredprocedurename,
  groomstoredprocedurename,
  maxdataagedays,
  groomingintervalminutes
FROM standarddatasetaggregation
WHERE buildaggregationstoredprocedurename = 'AemAggregate'

--/* Top Noisy Rules in the last 24 hours */
SELECT managedentitytypesystemname,
  discoverysystemname,
  Count(*) AS 'Changes'
FROM
  (
    SELECT DISTINCT MP.managementpacksystemname,
      MET.managedentitytypesystemname,
      propertysystemname,
      D.discoverysystemname,
      D.discoverydefaultname,
      MET1.managedentitytypesystemname AS 'TargetTypeSystemName',
      MET1.managedentitytypedefaultname 'TargetTypeDefaultName',
      ME.path,
      ME.NAME,
      C.oldvalue,
      C.newvalue,
      C.changedatetime
    FROM dbo.vmanagedentitypropertychange C
      INNER JOIN dbo.vmanagedentity ME ON ME.managedentityrowid=C.managedentityrowid
      INNER JOIN dbo.vmanagedentitytypeproperty METP ON METP.propertyguid=C.propertyguid
      INNER JOIN dbo.vmanagedentitytype MET ON MET.managedentitytyperowid=ME.managedentitytyperowid
      INNER JOIN dbo.vmanagementpack MP ON MP.managementpackrowid=MET.managementpackrowid
      INNER JOIN dbo.vmanagementpackversion MPV ON MPV.managementpackrowid=MP.managementpackrowid
      LEFT JOIN dbo.vdiscoverymanagementpackversion DMP ON DMP.managementpackversionrowid=MPV.managementpackversionrowid
        AND Cast(definitionxml.query('data(/Discovery/DiscoveryTypes/DiscoveryClass/@TypeID)') AS NVARCHAR(max))
        LIKE '%'+MET.managedentitytypesystemname+'%'
      LEFT JOIN dbo.vmanagedentitytype MET1 ON MET1.managedentitytyperowid=DMP.targetmanagedentitytyperowid
      LEFT JOIN dbo.vdiscovery D ON D.discoveryrowid=DMP.discoveryrowid
      WHERE changedatetime > Dateadd(hh,-24,Getutcdate())
    ) AS #T
GROUP BY managedentitytypesystemname, discoverysystemname
ORDER BY Count(*) DESC

--/* Modified properties in the last 24 hours */
SELECT DISTINCT MP.managementpacksystemname,
  MET.managedentitytypesystemname,
  propertysystemname,
  D.discoverysystemname, D.discoverydefaultname,
  MET1.managedentitytypesystemname AS 'TargetTypeSystemName',
  MET1.managedentitytypedefaultname 'TargetTypeDefaultName',
  ME.path,
  ME.NAME,
  C.oldvalue,
  C.newvalue,
  C.changedatetime
FROM dbo.vmanagedentitypropertychange C
  INNER JOIN dbo.vmanagedentity ME ON ME.managedentityrowid=C.managedentityrowid
  INNER JOIN dbo.vmanagedentitytypeproperty METP ON METP.propertyguid=C.propertyguid
  INNER JOIN dbo.vmanagedentitytype MET ON MET.managedentitytyperowid=ME.managedentitytyperowid
  INNER JOIN dbo.vmanagementpack MP ON MP.managementpackrowid=MET.managementpackrowid
  INNER JOIN dbo.vmanagementpackversion MPV ON MPV.managementpackrowid=MP.managementpackrowid
  LEFT JOIN dbo.vdiscoverymanagementpackversion DMP ON DMP.managementpackversionrowid=MPV.managementpackversionrowid
    AND Cast(definitionxml.query('data(/Discovery/DiscoveryTypes/DiscoveryClass/@TypeID)') AS NVARCHAR(max))
    LIKE '%'+MET.managedentitytypesystemname+'%'
  LEFT JOIN dbo.vmanagedentitytype MET1 ON MET1.managedentitytyperowid=DMP.targetmanagedentitytyperowid
  LEFT JOIN dbo.vdiscovery D ON D.discoveryrowid=DMP.discoveryrowid
WHERE changedatetime > Dateadd(hh,-24,Getutcdate())
ORDER BY MP.managementpacksystemname, MET.managedentitytypesystemname

--Aggregation historyUSE operationsmanagerdw
;WITH aggregationinfo AS (
    SELECT aggregationtype =
      CASE
        WHEN aggregationtypeid = 0 THEN 'Raw'
        WHEN aggregationtypeid = 20 THEN 'Hourly'
        WHEN aggregationtypeid = 30 THEN 'Daily'
        ELSE NULL
      END
      ,aggregationtypeid
      ,Min(aggregationdatetime) AS 'TimeUTC_NextToAggregate'
      ,Count(aggregationdatetime) AS 'Count_OutstandingAggregations'
      ,datasetid
    FROM standarddatasetaggregationhistory
    WHERE lastaggregationdurationseconds IS NULL
    GROUP BY datasetid, aggregationtypeid
)
SELECT
sds.schemaname
,ai.aggregationtype
,ai.timeutc_nexttoaggregate
,count_outstandingaggregations
,sda.maxdataagedays
,sda.lastgroomingdatetime
,sds.debuglevel
,ai.datasetid
FROM standarddataset AS sds WITH(nolock)
  JOIN aggregationinfo AS ai WITH(nolock) ON sds.datasetid = ai.datasetid
  JOIN dbo.standarddatasetaggregation AS sda WITH(nolock) ON sda.datasetid = sds.datasetid AND sda.aggregationtypeid = ai.aggregationtypeid
ORDER BY schemaname DESC

--Rules creating the most insertsSELECT TOP(30) vr.rulesystemname, Count (*) AS 'count'
FROM [Perf].[perfhourly_99d5c26784f74ba0b17d726400d58097] ph
INNER JOIN performanceruleinstance pri ON ph.performanceruleinstancerowid = pri.performanceruleinstancerowid
INNER JOIN vrule vr ON pri.rulerowid = vr.rulerowid
GROUP BY vr.rulesystemname
ORDER BY count DESC

--Instances with the most perf inserts
SELECT TOP(30) vme.fullname,
  Count (*) AS 'count'
FROM [Perf].[perfhourly_99d5c26784f74ba0b17d726400d58097] ph
  INNER JOIN vmanagedentity vme ON ph.managedentityrowid = vme.managedentityrowid
GROUP BY vme.fullname
ORDER BY count DESC

--Instance types with the most perf inserts
SELECT TOP(30) vmet.managedentitytypesystemname,
  Count (*) AS 'count'
FROM [Perf].[perfhourly_99d5c26784f74ba0b17d726400d58097] ph
  INNER JOIN vmanagedentity vme ON ph.managedentityrowid = vme.managedentityrowid
  INNER JOIN vmanagedentitytype vmet ON vmet.managedentitytyperowid = vme.managedentitytyperowid
GROUP BY vmet.managedentitytypesystemname
ORDER BY count DESC

--Find the current Perf partition table
SELECT TOP(1) tableguid,
  tartdatetime,
  enddatetime
FROM standarddatasettablemap sdtm
  INNER JOIN standarddataset sd ON sd.datasetid = sdtm.datasetid
WHERE aggregationtypeid = '20'
AND sd.schemaname = 'Perf'
ORDER BY sdtm.enddatetime DESC
