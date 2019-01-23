SELECT *
	INTO dbo.AuditLog
    FROM sys.fn_get_audit_file('C:\AuditLog\*.*', DEFAULT, DEFAULT)
    