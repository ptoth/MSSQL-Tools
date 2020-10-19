EXEC sp_configure 'show advanced option', 1;
RECONFIGURE WITH OVERRIDE;

EXEC sp_configure 'Database Mail XPs',1
RECONFIGURE WITH OVERRIDE;

DECLARE @ServerName varchar(30) = CONVERT(varchar,(SELECT SERVERPROPERTY('MachineName')))
DECLARE @domain varchar(30) = 'myCompanyDomain.org'
DECLARE @mailServerAddress varchar(30) = 'mail.server.org'
DECLARE @emailAddress varchar(100) = 'mailerDaemon'+'_'+ @ServerName +'@'+ @domain;
DECLARE @mailSubject varchar (40) ='Test message from '+ @ServerName

IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_profile WHERE  name = 'mailerDaemon')  
	BEGIN 
		--CREATE Profile [mailerDaemon] 
		EXECUTE msdb.dbo.sysmail_add_profile_sp 
		@profile_name = 'mailerDaemon', 
		@description  = 'MailerDaemon'; 
	END --IF EXISTS profile 

 IF NOT EXISTS(SELECT * FROM msdb.dbo.sysmail_account WHERE name = 'mailerDaemon') 
	BEGIN 
		--CREATE Account [mailerDaemon] 
		EXECUTE msdb.dbo.sysmail_add_account_sp 
		@account_name            = 'mailerDaemon', 
		@email_address           = @emailAddress,
		@display_name            = @ServerName, 
		@replyto_address         = '', 
		@description             = '', 
		@mailserver_name         = @mailServerAddress, 
		@mailserver_type         = 'SMTP', 
		@port                    = '25', 
		@username                =  NULL , 
		@password                =  NULL ,  
		@use_default_credentials =  0 , 
		@enable_ssl              =  0 ; 
	END --IF EXISTS  account 

 IF NOT EXISTS(
	SELECT * 
    FROM msdb.dbo.sysmail_profileaccount pa 
    	INNER JOIN msdb.dbo.sysmail_profile p ON pa.profile_id = p.profile_id 
    	INNER JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id   
    WHERE p.name = 'mailerDaemon' 
    AND a.name = 'mailerDaemon')  

BEGIN 
	-- Associate Account [mailerDaemon] to Profile [mailerDaemon] 
	EXECUTE msdb.dbo.sysmail_add_profileaccount_sp 
		@profile_name = 'mailerDaemon', 
		@account_name = 'mailerDaemon', 
		@sequence_number = 1 ; 
END

EXEC msdb.dbo.sp_send_dbmail 
	@profile_name='mailerDaemon',
	@recipients='username@domain.org',
	@subject=@mailSubject,
	@body='This is the body of the test message. Congrates Database Mail Received By you Successfully.'



/* To test:
DECLARE @ServerName varchar(30) = CONVERT(varchar,(SELECT SERVERPROPERTY('MachineName')))
DECLARE @mailSubject varchar (40) ='Test message from '+ @ServerName

EXEC msdb.dbo.sp_send_dbmail 
	@profile_name='mailerDaemon',
	@recipients='targetEmail@domain.org',
	@subject=@mailSubject,
	@body='This is the body of the test message. Congrates Database Mail Received By you Successfully.'
*/