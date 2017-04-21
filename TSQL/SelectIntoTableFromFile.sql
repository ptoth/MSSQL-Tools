SELECT *
  INTO <tableName>
  FROM ::fn_trace_gettable('C:\CASES\trace.trc', default)
  --WHERE SPID=295
