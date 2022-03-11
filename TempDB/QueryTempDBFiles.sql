use tempdb;
go
select
    name,
    cast((size/128.0) as int) as TotalSpaceInMB,
    cast((cast(fileproperty(name, 'SpaceUsed') as int)/128.0) as int) as UsedSpaceInMB,
    cast((size/128.0 - cast(fileproperty(name, 'SpaceUsed') AS int)/128.0) as int) as FreeSpaceInMB
from
    sys.database_files
order by name
