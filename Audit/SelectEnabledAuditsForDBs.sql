DECLARE @command varchar(2000) 
SELECT @command = '
USE [?]

IF EXISTS ( 
	SELECT	*
		FROM sys.server_audits AS a
		JOIN sys.database_audit_specifications AS s ON a.audit_guid = s.audit_guid
		JOIN sys.database_audit_specification_details AS d ON s.database_specification_id = d.database_specification_id
	WHERE s.is_state_enabled = 1
)
BEGIN
	SELECT	''?'' as DatabaseName,
			a.audit_id,
			a.name as audit_name,
			s.name as database_specification_name,
			d.audit_action_name,
			s.is_state_enabled,
			d.is_group,
			s.create_date,
			s.modify_date,
			d.audited_result
	FROM sys.server_audits AS a
		JOIN sys.database_audit_specifications AS s ON a.audit_guid = s.audit_guid
		JOIN sys.database_audit_specification_details AS d ON s.database_specification_id = d.database_specification_id
	WHERE s.is_state_enabled = 1
END
ELSE
BEGIN
	SELECT ''?'' as DatabaseName, 
	0 as ''audit_id'',
	''No_DB_Audit_Enabled'' as ''audit_name'',
	''NA'' as ''database_specification_name'',
	''NA'' as ''audit_action_name'',
	''0'' as ''is_state_enabled'',
	''0'' as ''is_group'',
	GETDATE() as ''create_date'',
	GETDATE() as ''modify_date'',
	''NA'' as ''audited_result''
END
'
EXEC sp_MSforeachdb @command