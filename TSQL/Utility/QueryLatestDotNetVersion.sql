declare @dotNetVersion int

exec master.dbo.xp_regread 
    N'HKEY_LOCAL_MACHINE',
    N'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full',
    N'Release',
    @dotNetVersion output

SELECT 
	CASE @dotNetVersion
		-- Net 4.5
		WHEN 378389 THEN '.NET Framework 4.5'
		WHEN 461814 THEN '.NET Framework 4.5'
		
		WHEN 378675 THEN '.NET Framework 4.5.1'
		WHEN 378758 THEN '.NET Framework 4.5.1'

		WHEN 379893 THEN '.NET Framework 4.5.2'

		WHEN 393295 THEN '.NET Framework 4.6'
		WHEN 393297 THEN '.NET Framework 4.6'
		
		WHEN 394254 THEN '.NET Framework 4.6.1'
		WHEN 394271 THEN '.NET Framework 4.6.1'

		WHEN 394802 THEN '.NET Framework 4.6.2'
		WHEN 394806 THEN '.NET Framework 4.6.2'

		WHEN 460798 THEN '.NET Framework 4.7'
		WHEN 460805 THEN '.NET Framework 4.7'

		
		WHEN 461308 THEN '.NET Framework 4.7.1'
		WHEN 461310 THEN '.NET Framework 4.7.1'
		
		WHEN 461808 THEN '.NET Framework 4.7.2'
		WHEN 461814 THEN '.NET Framework 4.7.2'
		
		WHEN 528040 THEN '.NET Framework 4.8'
		WHEN 528049 THEN '.NET Framework 4.8'
		
		ELSE 'Unlisted .Net version, check!'
	END AS DotNetVersion