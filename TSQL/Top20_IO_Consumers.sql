;WITH high_io_queries AS
(
    SELECT TOP 20
        query_hash,
        Sum(total_logical_reads + total_logical_writes) io
    FROM sys.dm_exec_query_stats
    WHERE query_hash <> 0x0
    GROUP BY query_hash
    ORDER BY Sum(total_logical_reads + total_logical_writes) DESC
)
SELECT @@servername AS servername,
    COALESCE(Db_name(st.dbid), Db_name(Cast(pa.value AS INT)), 'Resource') AS [DatabaseName],
    COALESCE(Object_name(st.objectid, st.dbid), '<none>') AS [object_name],
    qs.query_hash,
    qs.total_logical_reads + total_logical_writes AS total_io,
    qs.execution_count,
    Cast((total_logical_reads + total_logical_writes) / (execution_count + 0.0) AS MONEY) AS average_io,
    io AS total_io_for_query,
    Substring(st.[text],(qs.statement_start_offset + 2) / 2,
        (CASE
            WHEN qs.statement_end_offset = -1  THEN Len(CONVERT(NVARCHAR(max),st.[text])) * 2
            ELSE qs.statement_end_offset + 2
            END - qs.statement_start_offset) / 2) AS sql_text,
    qp.query_plan
FROM sys.dm_exec_query_stats qs
JOIN high_io_queries fq
    ON fq.query_hash = qs.query_hash
CROSS apply sys.Dm_exec_sql_text(qs.sql_handle) st
CROSS apply sys.Dm_exec_query_plan (qs.plan_handle) qp
OUTER apply sys.Dm_exec_plan_attributes(qs.plan_handle) pa
WHERE pa.attribute = 'dbid'
ORDER BY fq.io DESC,
    fq.query_hash,
    qs.total_logical_reads + total_logical_writes DESC
OPTION (recompile)
