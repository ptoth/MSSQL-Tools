create table #ls
(
   name varchar(255),
   LogSize real,
   LogSpaceUsed real,
   Status int
)

insert #ls
exec ('dbcc sqlperf(logspace)')

declare @name varchar(255), @sql varchar(1000);

select d.name, DATABASEPROPERTYEX(d.name, 'Status') Status,
   case when DATABASEPROPERTYEX(d.name, 'IsAutoCreateStatistics') = 1
      then 'ON' else 'OFF' end AutoCreateStatistics,
   case when DATABASEPROPERTYEX(d.name, 'IsAutoUpdateStatistics') = 1
      then 'ON' else 'OFF' end AutoUpdateStatistics,
   case when DATABASEPROPERTYEX(d.name, 'IsAutoShrink') = 1
      then 'ON' else 'OFF' end AutoShrink,
   case when DATABASEPROPERTYEX(d.name, 'IsAutoClose') = 1
      then 'ON' else 'OFF' end AutoClose,
   DATABASEPROPERTYEX(d.name, 'Collation') Collation,
   DATABASEPROPERTYEX(d.name, 'Updateability') Updateability,
   DATABASEPROPERTYEX(d.name, 'UserAccess') UserAccess,
   replace(page_verify_option_desc, '_', ' ') PageVerifyOption,
   d.compatibility_level CompatibilityLevel,
   DATABASEPROPERTYEX(d.name, 'Recovery') RecoveryModel,
   convert(bigint, 0) as Size, convert(bigint, 0) Used,
   case when sum(NumberReads+NumberWrites) > 0
      then sum(IoStallMS)/sum(NumberReads+NumberWrites) else -1 end AvgIoMs,
   ls.LogSize, ls.LogSpaceUsed,
   b.backup_start_date LastBackup
into #dbs1
from master.sys.databases as d
   left join msdb..backupset b
   on d.name = b.database_name and b.backup_start_date = (
      select max(backup_start_date)
      from msdb..backupset
      where database_name = b.database_name
         and type = 'D')
   left join ::fn_virtualfilestats(-1, -1) as vfs
   on d.database_id = vfs.DbId
   join #ls as ls
   on d.name = ls.name
group by d.name, DATABASEPROPERTYEX(d.name, 'Status'), 
case when DATABASEPROPERTYEX(d.name, 'IsAutoCreateStatistics') = 1
   then 'ON' else 'OFF' end, 
case when DATABASEPROPERTYEX(d.name, 'IsAutoUpdateStatistics') = 1
   then 'ON' else 'OFF' end, 
case when DATABASEPROPERTYEX(d.name, 'IsAutoShrink') = 1
   then 'ON' else 'OFF' end, 
case when DATABASEPROPERTYEX(d.name, 'IsAutoClose') = 1
   then 'ON' else 'OFF' end, 
DATABASEPROPERTYEX(d.name, 'Collation'), 
DATABASEPROPERTYEX(d.name, 'Updateability'), 
DATABASEPROPERTYEX(d.name, 'UserAccess'), 
page_verify_option_desc, 
d.compatibility_level, 
DATABASEPROPERTYEX(d.name, 'Recovery'), 
ls.LogSize, ls.LogSpaceUsed, b.backup_start_date;

create table #dbsize1
(
   fileid int,
   filegroup int,
   TotalExtents bigint,
   UsedExtents bigint,
   dbname varchar(255),
   FileName varchar(255)
);

declare c1 cursor for select name
from #dbs1;
open c1;

fetch next from c1 into @name;
while @@fetch_status = 0 
begin
   set @sql = 'use [' + @name + ']; DBCC SHOWFILESTATS WITH NO_INFOMSGS;'
   insert #dbsize1
   exec(@sql);
   update #dbs1 
   set Size = (select sum(TotalExtents) / 16
   from #dbsize1),
      Used = (select sum(UsedExtents) / 16
   from #dbsize1) 
   where name = @name;
   truncate table #dbsize1;
   fetch next from c1 into @name;
end;
close c1;
deallocate c1;

select *
from #dbs1
order by name;

drop table #dbsize1;
drop table #dbs1;
drop table #ls;