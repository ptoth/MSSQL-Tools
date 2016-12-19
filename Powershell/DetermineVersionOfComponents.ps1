<# The sample scripts are not supported under any Microsoft standard support 
 program or service. The sample scripts are provided AS IS without warranty  
 of any kind. Microsoft further disclaims all implied warranties including,  
 without limitation, any implied warranties of merchantability or of fitness for 
 a particular purpose. The entire risk arising out of the use or performance of  
 the sample scripts and documentation remains with you. In no event shall 
 Microsoft, its authors, or anyone else involved in the creation, production, or 
 delivery of the scripts be liable for any damages whatsoever (including, 
 without limitation, damages for loss of business profits, business interruption, 
 loss of business Information, or other pecuniary loss) arising out of the use 
 of or inability to use the sample scripts or documentation, even if Microsoft 
 has been advised of the possibility of such damages 
#>
param
(
    [parameter(mandatory=$true)]
    [string]$ServerInstance,
    [parameter(mandatory=$true)]
    [string]$UserName,
    [parameter(mandatory=$true)]
    [string]$Password
)

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null 
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null  
$ServerConnection =new-object "Microsoft.SqlServer.Management.Common.ServerConnection" $ServerInstance,$UserName,$Password 
$Server=New-Object "Microsoft.SqlServer.Management.Smo.Server" $ServerConnection

Try
{
    $ServerConnection.Connect()
    Write-Host $ServerInstance "Connection to SQL Server is successful." 
}
Catch
{ 
    Write-Host $ServerInstance "Connection to SQL Server failed." 
    EXIT
}


$VersionMajor = $Server.VersionMajor 

[string]$m=$PSVersionTable.CLRVersion.Major 
[string]$n=$PSVersionTable.CLRVersion.Minor
$DotnetVersion=$m+"."+$n

switch($VersionMajor)
{
    13  {$Version = 13    ;$Number=130}
    12  {$Version = 12    ;$Number=120}
    11  {$Version = 11    ;$Number=110}
    10.5{$Version = 10_50 ;$Number=100}
    10  {$Version = 10    ;$Number=100}
}


function Get-RegistryKeyContent($key,$value) { 
    (Get-ItemProperty -Path $key $value -ErrorAction SilentlyContinue).$value 
} 


#SQL Server Analysis Services
$SSAS = Get-RegistryKeyContent "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSAS$Version.MSSQLSERVER\MSSQLServer\CurrentVersion" CurrentVersion 
#SQL Server Reporting Services
$SSRS = Get-RegistryKeyContent "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSRS$Version.MSSQLSERVER\MSSQLServer\CurrentVersion" CurrentVersion 
#SQL Server Integration Services
$SSIS = Get-RegistryKeyContent "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$Number\DTS\Setup" Version 

#SQL Server Master Data Services(SQL Server 2008 R2 or higher)
$MDS = Get-RegistryKeyContent "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$Number\Master Data Services\CurrentVersion" Version 

#Native Client
if($Version -lt 11)
{
    $NativeClient = Get-RegistryKeyContent "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\SQLNCLI10\CurrentVersion" Version
} 
else
{
    $NativeClient = Get-RegistryKeyContent "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\SQLNCLI$Version\CurrentVersion" Version
}

#SQLWriter
$SQLWriter = Get-RegistryKeyContent "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\SqlWriter\CurrentVersion" Version 
#Full-Text Search
$FullText = Get-RegistryKeyContent "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL$Version.MSSQLSERVER\Setup\SQL_FullText_Adv" Version

Write-Host "------------------------------------------------------------"
Write-Host "Component Name:                  Version Number:" 
Write-Host "------------------------------------------------------------"
Write-Host ".NET Framework:                 " $DotnetVersion
Write-Host "SQL Server Analysis Services:   " $SSAS
Write-Host "SQL Server Reporting Services:  " $SSRS
Write-Host "SQL Server Integration Services:" $SSIS
Write-Host "SQL Server Master Data Services:" $MDS
Write-Host "SQL Server Native Client:       " $NativeClient
Write-Host "SQLWriter:                      " $SQLWriter
Write-Host "SQL Server Full-Text Search:    " $FullText
Write-Host "------------------------------------------------------------"