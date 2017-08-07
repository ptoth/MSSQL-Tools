SELECT top 10
    SUBSTRING(t.text, ( s.statement_start_offset / 2 ) + 1,
    ( ( CASE statement_end_offset
        WHEN -1 
            THEN DATALENGTH(t.text)
            ELSE s.statement_end_offset
        END - s.statement_start_offset ) / 2 ) + 1)
    AS statement_text,
    text,
    objtype,
    cacheobjtype,
    usecounts,
    last_execution_time,
    total_worker_time,
    total_worker_time / execution_count AS [Avg CPU Time],
    execution_count ,
    qp.query_plan
FROM sys.dm_exec_query_stats AS s
    inner join sys.dm_exec_cached_plans cp
    on s.plan_handle = cp.plan_handle
CROSS APPLY sys.dm_exec_sql_text(s.sql_handle) AS t
CROSS APPLY sys.dm_exec_query_plan(s.plan_handle) qp
order by total_worker_time desc
