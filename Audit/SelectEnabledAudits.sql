IF EXISTS ( 
	SELECT *
	FROM sys.server_audits AS a
		JOIN sys.server_audit_specifications AS s ON a.audit_guid = s.audit_guid
		JOIN sys.server_audit_specification_details AS d ON s.server_specification_id = d.server_specification_id
	WHERE s.is_state_enabled = 1
)
BEGIN
	-- select audit details
	SELECT audit_id, 
		a.name as audit_name, 
		s.name as server_specification_name,
		d.audit_action_name,
		s.is_state_enabled,
		d.is_group,
		d.audit_action_id,	
		s.create_date,
		s.modify_date
	FROM sys.server_audits AS a 
		JOIN sys.server_audit_specifications AS s ON a.audit_guid = s.audit_guid
		JOIN sys.server_audit_specification_details AS d ON s.server_specification_id = d.server_specification_id
	WHERE s.is_state_enabled = 1
END
ELSE
BEGIN
    SELECT 0 as audit_id,
		'No_audit_enabled' as audit_name,
		'NA' as server_specification_name,
		'NA' as audit_action_name,
		0 as is_state_enabled,
		0 as is_group,
		'NA' as audit_action_id,
		GETDATE() as create_date,
		GETDATE() as modify_date

END
