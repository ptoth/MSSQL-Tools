;WITH high_cpu_queries AS
(
    SELECT TOP 20
        query_hash,
        Sum(total_worker_time) cpuTime
    FROM sys.dm_exec_query_stats
    WHERE query_hash <> 0x0
    GROUP BY query_hash
    ORDER BY Sum(total_worker_time) DESC
)
SELECT @@servername AS server_name,
    COALESCE(Db_name(st.dbid), Db_name(Cast(pa.value AS INT)), 'Resource') AS [DatabaseName],
    COALESCE(Object_name(ST.objectid, ST.dbid), '<none>') AS [object_name],
    qs.query_hash,
    qs.total_worker_time AS cpu_time,
    qs.execution_count,
    Cast(total_worker_time / (execution_count + 0.0) AS MONEY) AS average_CPU_in_microseconds,
    cputime AS total_cpu_for_query,
    Substring(ST.text,(QS.statement_start_offset + 2) / 2,
        (CASE
            WHEN QS.statement_end_offset = -1  THEN Len(CONVERT(NVARCHAR(max),ST.text)) * 2
            ELSE QS.statement_end_offset
            END - QS.statement_start_offset) / 2) AS sql_text,
    qp.query_plan
FROM sys.dm_exec_query_stats qs
JOIN high_cpu_queries hcq
    ON hcq.query_hash = qs.query_hash
CROSS apply sys.Dm_exec_sql_text(qs.sql_handle) st
CROSS apply sys.Dm_exec_query_plan (qs.plan_handle) qp
OUTER apply sys.Dm_exec_plan_attributes(qs.plan_handle) pa
WHERE pa.attribute = 'dbid'
ORDER BY hcq.cputime DESC,
    hcq.query_hash,
    qs.total_worker_time DESC
OPTION (recompile)
