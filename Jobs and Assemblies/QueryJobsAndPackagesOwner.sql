-- Jobs
SELECT s.name, l.name
FROM msdb..sysjobs s
LEFT JOIN master.sys.syslogins l on s.owner_sid = l.sid

-- Packages
SELECT s.name, l.name
FROM msdb..sysssispackages s
LEFT JOIN master.sys.syslogins l on s.ownersid = l.sid