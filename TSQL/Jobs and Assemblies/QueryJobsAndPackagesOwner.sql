-- Jobs

select s.name,l.name
 from  msdb..sysjobs s 
 left join master.sys.syslogins l on s.owner_sid = l.sid

-- Packages

select s.name,l.name 
from msdb..sysssispackages s 
 left join master.sys.syslogins l on s.ownersid = l.sid