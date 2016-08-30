-- Lists currently executing requests

SELECT Requests.session_id
    , Requests.status
    , Requests.start_time
    , Requests.command
    , SQL.text
    , Requests.wait_time
    , Requests.cpu_time
    , Requests.total_elapsed_time
    , Requests.reads
    , Requests.writes
    , Requests.logical_reads
    , Requests.transaction_isolation_level
    , Requests.*
FROM sys.dm_exec_requests Requests
CROSS APPLY sys.dm_exec_sql_text(Requests.sql_handle) SQL
