SELECT
    sys.objects.name,
    sys.indexes.name
FROM sys.indexes
    INNER JOIN sys.objects ON sys.objects.object_id = sys.indexes.object_id
WHERE sys.indexes.is_disabled = 1
ORDER BY
    sys.objects.name,
    sys.indexes.name

ALTER INDEX [AK_Address_rowguid] ON Person.Address DISABLE
GO
ALTER INDEX [IX_Address_AddressLine1_AddressLine2_City_StateProvinceID_PostalCode] ON Person.Address DISABLE
GO
ALTER INDEX [IX_Address_StateProvinceID] ON Person.Address DISABLE
GO

ALTER INDEX [AK_Address_rowguid] ON Person.Address REBUILD
GO
ALTER INDEX [IX_Address_AddressLine1_AddressLine2_City_StateProvinceID_PostalCode] ON Person.Address REBUILD
GO
ALTER INDEX [IX_Address_StateProvinceID] ON Person.Address REBUILD
GO