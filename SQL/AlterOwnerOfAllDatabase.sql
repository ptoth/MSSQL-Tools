/*Query owner of tha databases */
SELECT		name AS DataBaseName,
			SUSER_SNAME(owner_sid) AS OwnerUser
FROM 		sys.databases
WHERE 		SUSER_SNAME(owner_sid) != 'sa'
ORDER BY 	DataBaseName;
	
/* Execute altering SP for all database */
--EXEC sp_MSforeachdb 'EXEC [?]..sp_changedbowner ''sa'' '

SELECT	@@SERVERNAME AS DB,
		name AS DataBaseName,
		SUSER_SNAME(owner_sid) AS OwnerUser
FROM 	sys.databases
WHERE 	SUSER_SNAME(owner_sid) != 'sa'
	AND SUSER_SNAME(owner_sid) != 'TECH01\_systemcenterinstall'
	AND SUSER_SNAME(owner_sid) != 'TECH01\_CCS_service'
	AND SUSER_SNAME(owner_sid) != 'TECH01\_SystemCenterInstall'
	AND SUSER_SNAME(owner_sid) != 'TECH01\_svom_service_accoun'
ORDER BY DB DESC;

USE QControl9; EXEC [QControl9]..sp_changedbowner 'sa';
