SELECT *
INTO dbo.tableName
FROM ::fn_trace_gettable('C:\trace.trc', default)
  --WHERE SPID=295
