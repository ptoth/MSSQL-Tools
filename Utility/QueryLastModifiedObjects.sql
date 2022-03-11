-- declarations
DECLARE
    @current VARCHAR(255),
    @start VARCHAR(255),
    @index INT;

-- find your trace path
SELECT @current = path
FROM sys.traces
WHERE is_default = 1;

SET @current = REVERSE(@current)
SELECT @index = PATINDEX('%\%', @current)
SET @current = REVERSE(@current)
SET @start = LEFT(@current, LEN(@current) - @index) + '\log.trc';

-- query on the eventclasses for delete and alter
SELECT CASE
    EventClass 
        WHEN 164 THEN 'Object:Altered'
        WHEN 47 THEN 'Object:Deleted' 
        END [Action],
    DatabaseName,
    ObjectName,
    HostName,
    ApplicationName,
    LoginName,
    StartTime
FROM::fn_trace_gettable(@start, DEFAULT)
WHERE EventClass IN (164,47)
    AND EventSubclass = 0
    AND DatabaseID <> 2