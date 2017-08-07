-- Set startup mode -m switch (Single User Mode)
-- Login via cmd:
sqlcmd -s servername/instance

-- Enable SA login, if not enabled
ALTER login sa enable
go

-- Update SA password
Sp_password NULL,'new_password_here','sa'
go

-- Exit the prompt
Quit