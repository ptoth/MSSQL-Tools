;with high_cpu_queries as
(
    SELECT top 20 
        query_hash, 
        SUM(total_worker_time) cpuTime
    FROM sys.dm_exec_query_stats 
    WHERE query_hash <> 0x0
    GROUP BY query_hash
    ORDER BY SUM(total_worker_time) DESC
)
SELECT @@servername AS server_name,
    coalesce(db_name(st.dbid), db_name(cast(pa.value AS INT)), 'Resource') AS [DatabaseName],
    coalesce(object_name(st.objectid, st.dbid), '<none>') AS [object_name],
    qs.query_hash,
    qs.total_worker_time AS cpu_time,
    qs.execution_count,
    cast(total_worker_time / (execution_count + 0.0) AS money) AS average_CPU_in_microseconds,
    cpuTime AS total_cpu_for_query,
    SUBSTRING(st.[text],(qs.statement_start_offset + 2) / 2,
        (CASE 
            WHEN qs.statement_end_offset = -1  THEN LEN(CONVERT(NVARCHAR(MAX),st.[text])) * 2
            ELSE qs.statement_end_offset + 2
            END - qs.statement_start_offset) / 2) AS sql_text,
    qp.query_plan
FROM sys.dm_exec_query_stats qs
join high_cpu_queries hcq
    on hcq.query_hash = qs.query_hash
cross apply sys.dm_exec_sql_text(qs.sql_handle) st
cross apply sys.dm_exec_query_plan (qs.plan_handle) qp
outer apply sys.dm_exec_plan_attributes(qs.plan_handle) pa
WHERE pa.attribute = 'dbid'
ORDER BY hcq.cpuTime DESC,
    hcq.query_hash,
    qs.total_worker_time DESC
option (recompile)