-- Set startup mode -m switch (Single User Mode)
-- Login via cmd:
sqlcmd -S servername/instance

-- Enable SA login, if not enabled
alter login sa enable
go
-- Update SA password
sp_password NULL,'new_password_here','sa'
go
-- Exit the prompt
quit
