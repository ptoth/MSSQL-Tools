SELECT 
	serverproperty('machinename') as 'Server Name',
	isnull(serverproperty('instancename'),serverproperty('machinename')) as 'Instance Name', 
	[name],
	[default_database_name],
	IS_SRVROLEMEMBER('sysadmin', name) as 'Sysadmin?',
	[is_policy_checked] as 'PWD policy checked?',
	[is_disabled] as 'Disabled?',
	--[password_hash],
    PWDCOMPARE(name, password_hash) as 'Username as PWD?',
	'ALTER LOGIN ['+[name]+'] WITH DEFAULT_DATABASE=['+[default_database_name]+'], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON' as 'SetPolicyTo1_TSQL'
FROM master.sys.sql_logins 
WHERE [is_policy_checked] = 0 
	--OR [is_expiration_checked] = 0
	--AND PWDCOMPARE(name, password_hash) = 1
	and name not like '##MS_%'
	and name != 'sa'
	and (serverproperty('machinename') = 'MPSQL08DB01')