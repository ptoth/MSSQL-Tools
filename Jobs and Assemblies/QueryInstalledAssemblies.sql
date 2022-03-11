SELECT
    assembly = a.name,
    path     = f.name
FROM sys.assemblies AS a
    INNER JOIN sys.assembly_files AS f
    ON a.assembly_id = f.assembly_id
WHERE a.is_user_defined = 1;