-- Set startup mode -m switch (Single User Mode)
-- Login via cmd:
-- sqlcmd -s servername/instance

-- Enable SA login, if not enabled
ALTER login sa ENABLE
GO

-- Update SA password
Sp_password NULL,'123456789Xc','sa'
GO

-- Exit the prompt
