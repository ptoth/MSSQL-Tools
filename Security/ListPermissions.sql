SELECT 
    DP.class_desc AS object_type, 
    GR.type_desc AS grantor_user_type, 
    GR.name AS grantor, 
    GE.type_desc AS grantee_user_type, 
    GE.name AS grantee,
    DP.permission_name, state_desc,
    CASE
        WHEN S.name IS NOT NULL THEN S.name
        ELSE ISNULL(OBJECT_SCHEMA_NAME(DP.major_id), 'all_database')
    END AS [schema_name],
    CASE
        WHEN S.name  IS NOT NULL    THEN NULL
        ELSE OBJECT_NAME(DP.major_id)
    END AS [table_name]
FROM sys.database_permissions DP
    INNER JOIN sys.database_principals GR ON GR.principal_id = DP.grantor_principal_id
    INNER JOIN sys.database_principals GE ON GE.principal_id = DP.grantee_principal_id
    LEFT JOIN sys.schemas AS S ON S.schema_id = DP.major_id
WHERE NOT (ISNULL(OBJECT_SCHEMA_NAME(DP.major_id), 'all_database') = 'sys' 
    AND DP.class_desc = 'OBJECT_OR_COLUMN')