SELECT *
  INTO <tableName>
  FROM ::fn_trace_gettable('C:\CASES\output\output\AIMSDB_SQLDIAG_AIMSPROD_sp_trace.trc', default)
  WHERE SPID=295
