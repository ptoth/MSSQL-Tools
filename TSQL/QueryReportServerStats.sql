Use ReportServer
Go

SELECT Catalog.Name, 
    ExecutionLogStorage.UserName, 
    ExecutionLogStorage.InstanceName, 
    Catalog.Path, 
    COUNT(*) as NumberOfQueries
FROM ExecutionLogStorage 
    INNER JOIN Catalog 
        ON ExecutionLogStorage.ReportID = Catalog.ItemID
WHERE  (Catalog.Path LIKE N'%Database%') 
    AND (ExecutionLogStorage.TimeStart > CONVERT(DATETIME, '2017-01-01 00:00:00', 102))
GROUP BY Catalog.Name, 
    ExecutionLogStorage.UserName, 
    ExecutionLogStorage.InstanceName, 
    Catalog.Path
ORDER BY Catalog.Name, 
    ExecutionLogStorage.UserName
