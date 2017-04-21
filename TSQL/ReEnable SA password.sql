-- Set startup mode -m switch (Single User Mode)
-- Login via cmd:
sqlcmd -s servername/instance

-- Enable SA login, if not enabledALTER login sa enablego
-- Update SA passwordSp_password NULL,'new_password_here','sa'go
-- Exit the promptQuit