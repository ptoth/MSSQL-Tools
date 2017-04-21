-- Need to run per instance
-- instance configuration
EXEC sp_configure;

-- query databases
EXEC sp_helpdb;

-- SQL version
EXEC xp_msver;

-- Query extended Stored Procedures
EXEC sp_helpextendedproc;

-- Query system devices
SELECT *
    FROM sysdevices;

-- Query databases' files
SELECT *
    FROM sys.master_files;

-- Query loaded modules:
SELECT *
    FROM sys.dm_os_loaded_modules;

--Query Custom Assembly
  SELECT * FROM sys.assembly_modules

-- Linked Servers:
EXEC sp_linkedservers;
