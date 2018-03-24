SELECT cp.objtype AS ObjectType,
	OBJECT_NAME(st.objectid,st.dbid) AS ObjectName,
	cp.usecounts AS ExecutionCount,
	st.TEXT AS QueryText,
	qp.query_plan AS QueryPlan
FROM sys.dm_exec_cached_plans AS cp WITH (NOLOCK)
	CROSS APPLY sys.dm_exec_query_plan(cp.plan_handle) AS qp
	CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle) AS st
--WHERE OBJECT_NAME(st.objectid,st.dbid) = 'DataBaseName'
ORDER BY ExecutionCount DESC