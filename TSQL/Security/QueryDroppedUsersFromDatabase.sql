DECLARE @path NVARCHAR(260);

SELECT @path = REVERSE(SUBSTRING(REVERSE([path]), 
   CHARINDEX(CHAR(92), REVERSE([path])), 260)) + N'log.trc'
FROM sys.traces WHERE is_default = 1;

SELECT EventType = 
	CASE EventSubClass 
		WHEN 3 THEN 'CREATE_USER'
		WHEN 4 THEN 'DROP_USER' 
	END, 
	TargetUserName, LoginName, StartTime
FROM sys.fn_trace_gettable(@path, DEFAULT)
WHERE EventClass = 109 -- Create DB User Event
AND DatabaseName = N'myDb'
ORDER BY StartTime DESC;


/*
DECLARE @path NVARCHAR(260);

SELECT @path = REVERSE(SUBSTRING(REVERSE([path]), 
   CHARINDEX(CHAR(92), REVERSE([path])), 260)) + N'log.trc'
FROM sys.traces WHERE is_default = 1;

SELECT TargetUserName, LoginName, StartTime, TextData
FROM sys.fn_trace_gettable(@path, DEFAULT)
ORDER BY StartTime DESC;
*/