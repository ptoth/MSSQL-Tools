/* Disable All SQL Server Agent Jobs */
USE [msdb];
GO
UPDATE [msdb].[dbo].[sysjobs]
SET Enabled = 0
WHERE Enabled = 1;
GO
 
/* Enable All SQL Server Agent Jobs */
USE [msdb];
GO
UPDATE [msdb].[dbo].[sysjobs]
SET Enabled = 1
WHERE Enabled = 0;
GO
 
/* Disable Jobs By Job Name */
USE [msdb];
GO
UPDATE [msdb].[dbo].[sysjobs]
SET Enabled = 0
WHERE [Name] LIKE 'Admin%';
GO
 
/* Disable Jobs By Job Category */
USE [msdb];
GO
UPDATE J
SET J.Enabled = 0
FROM [msdb].[dbo].[sysjobs] J
INNER JOIN [msdb].[dbo].[syscategories] C
ON J.category_id = C.category_id
WHERE C.[Name] = 'Database Maintenance';
GO