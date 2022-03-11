-- show all the cached query plans. Unfortunately, no SQL text is shown there.
SELECT *
FROM sys.dm_exec_query_stats

-- join the SQL text to the plans like so:
SELECT
    plan_handle,
    creation_time,
    last_execution_time,
    execution_count,
    qt.text
FROM sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text (qs.[sql_handle]) AS qt

-- add a WHERE clause to find the SQL I know is in the query, and then I can execute:
DBCC FREEPROCCACHE (plan_handle_id_goes_here)
--OR 
DBCC FREESYSTEMCACHE ('ALL') WITH MARK_IN_USE_FOR_REMOVAL;

