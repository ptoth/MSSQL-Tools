-- Database audits can be targeted to roles. Create empty role and add users to them. Target the audit on them

USE [master]

/* CREATE SERVER AUDIT */
CREATE SERVER AUDIT [myInstance]
TO APPLICATION_LOG
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
	,AUDIT_GUID = 'f4052d1a-9334-4349-b23a-92ca5cc36faa'
)
GO

/* CREATE SERVER AUDIT SPECS */
USE [master]

CREATE SERVER AUDIT SPECIFICATION [ServerAuditSpecification_on_myInstance]
FOR SERVER AUDIT [myInstance]
ADD (DATABASE_OBJECT_ACCESS_GROUP), 
ADD (AUDIT_CHANGE_GROUP),
ADD (SUCCESSFUL_LOGIN_GROUP)
WITH (STATE = ON)
GO

/* CREATE EXCLUSIONS FOR INSTANCE LEVEL AUDIT */
ALTER SERVER AUDIT TestAudit WITH (STATE = OFF);
GO
ALTER SERVER AUDIT TestAudit WHERE server_principal_name <> N'%admin%';
GO
ALTER SERVER AUDIT TestAudit WITH (STATE = ON);
GO

/****** CREATE ROLE ******/
USE [myDatabase]
GO
CREATE ROLE [AuditedUsers]
GO

/****** Query database users ******/
SELECT name FROM sys.database_principals where (type='S' or type = 'U')

/* CREATE DATABASE AUDIT SPECS */
USE [myDatabase]
GO

CREATE DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification-myDatabase]
FOR SERVER AUDIT [myInstance]
ADD (BACKUP_RESTORE_GROUP),
ADD (SELECT ON DATABASE::[myDatabase] BY [AuditedUsers]),
ADD (INSERT ON DATABASE::[myDatabase] BY [AuditedUsers]),
ADD (UPDATE ON DATABASE::[myDatabase] BY [AuditedUsers]),
ADD (DELETE ON DATABASE::[myDatabase] BY [AuditedUsers]),
ADD (EXECUTE ON DATABASE::[myDatabase] BY [AuditedUsers])
WITH (STATE = ON)
GO


/* TEST UNDER DIFFERENT SECURITY CONTEXT */
SELECT SUSER_NAME(), USER_NAME();  
SELECT * from [myDatabase].[dbo].[Table]
REVERT;  

EXECUTE AS LOGIN = 'Domain\Username';  
SELECT SUSER_NAME(), USER_NAME();  
SELECT * from [myDatabase].[dbo].[Table]
REVERT;  

EXECUTE AS LOGIN = 'Domain\Username';  
SELECT SUSER_NAME(), USER_NAME();  
SELECT * from [SSD_DBA].[dbo].[Table]
REVERT;  


USE [myDatabase];
GO

CREATE TRIGGER CatchUser
ON DATABASE
FOR CREATE_USER, DROP_USER
AS
BEGIN
  SET NOCOUNT ON;
  EXEC sp_addrolemember 'AuditedUsers', 'UserMary'    
END