SELECT class_desc,*
FROM sys.server_permissions
WHERE grantor_principal_id = (
SELECT principal_id
FROM sys.server_principals
WHERE NAME = N'Domain\account')

SELECT NAME
,type_desc
FROM sys.server_principals
WHERE principal_id IN (
SELECT grantee_principal_id
FROM sys.server_permissions
WHERE grantor_principal_id = (
SELECT principal_id
FROM sys.server_principals
WHERE NAME = N'Domain\account'))