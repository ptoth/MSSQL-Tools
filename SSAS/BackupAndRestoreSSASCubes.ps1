Param (
    [Parameter(Mandatory=$true)][string]$SourceServer,
    [Parameter(Mandatory=$true)][string]$TargetServer,
    [Parameter(Mandatory=$true)][string]$BackupShareLocation,
    [Parameter(Mandatory=$false)][string]$Databases
)

trap [Exception] {
	write-error $("TRAPPED: " + $_.Exception.GetType().FullName)
	write-error $("TRAPPED: " + $_.Exception.Message)
	if ($src_server) {$src_server.disconnect()}
	if ($trg_server) {$trg_server.disconnect()}
	exit 1
}

$startTime = Get-Date

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.AnalysisServices") | out-null
$src_server = New-Object Microsoft.AnalysisServices.Server
$src_server.connect($SourceServer)
$trg_server = New-Object Microsoft.AnalysisServices.Server
$trg_server.connect($TargetServer)

$requestedDatabases = $null 

if($Databases) { $requestedDatabases = $Databases}

$available_databases = ($src_server.get_Databases() | foreach {$_.Name})

if ($requestedDatabases -eq $null) {
	$databasesToProcess = $available_databases}
else {
	$databasesToProcess = $requestedDatabases.Split(",")
	# Check that all specified databases actually exist on the server.
	foreach ($database in $databasesToProcess) {
		if ($available_databases -notcontains $database) {
			throw "$database does not exist on specified server."
		}
	}
}

# Backup all SSAS Cubes
# Query
$qryToBackup = '<Backup xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
  <Object>
    <DatabaseID><CHANGE_DB></DatabaseID>
  </Object>
  <File>\\SC41WFADBCLS51\Backup_share\<CHANGE_DB>.abf</File>
  <AllowOverwrite>true</AllowOverwrite>
  <ApplyCompression>false</ApplyCompression>
</Backup>'

$sum = 0

# Perform backup for every cube
foreach($database in ($src_server.get_Databases()| Where {$databasesToProcess -contains $_.Name})){
    Write-Output "======================================"
    Write-Output "$(Get-Date -Format "yyyy/MM/dd HH:mm:ss") - $($database.Name) - Started"
    $qry_exec = $qryToBackup.Replace("<CHANGE_DB>",$database.Name)
    Write-Output $qry_exec
    Write-Output "-----"
    $sum = $sum + $database.EstimatedSize
    Write-Output ("Database: {0}; Status: {1}; Size: {2} MB" -f $database.Name, $database.State, ($database.EstimatedSize/1024/1024).ToString("#,##0"))
    $src_server.Execute($qry_exec)
    Write-Output "$(Get-Date -Format "yyyy/MM/dd HH:mm:ss") - $($database.Name) - Finished"
}

#Restore all SSAS Cubes on target side
# Query
$qryToRestore = '<Restore xmlns="http://schemas.microsoft.com/analysisservices/2003/engine">
  <File>\\SC41WFADBCLS51\Backup_share\<CHANGE_DB>.abf</File>
  <AllowOverwrite>true</AllowOverwrite>
</Restore>'

$sum = 0

foreach($database in ($src_server.get_Databases()| Where {$databasesToProcess -contains $_.Name})){
    #$trg_server.connect($TargetServer)
    Write-Output "======================================"
    Write-Output "$(Get-Date -Format "yyyy/MM/dd HH:mm:ss") - $($database.Name) - Started"
    $qry_exec = $qryToRestore.Replace("<CHANGE_DB>",$database.Name)
    Write-Output $qry_exec
    Write-Output "-----"
    $sum = $sum + $database.EstimatedSize
    Write-Output ("Database: {0}; Status: {1}; Size: {2} MB" -f $database.Name, $database.State, ($database.EstimatedSize/1024/1024).ToString("#,##0"))
    $trg_server.Execute($qry_exec)
    Write-Output "$(Get-Date -Format "yyyy/MM/dd HH:mm:ss") - $($database.Name) - Finished"
}

Write-Output "========"
Write-Output "SUMMARY:"
Write-Output "========"
Write-Output "Source DB count:  $($src_server.Databases.Count)";
$trg_server.Refresh()
Write-Output "Target DB count:  $($trg_server.Databases.Count)";

$src_server.disconnect()
$trg_server.disconnect()

Write-Output ('Total Size Synchronized: {0} MB' -f ($sum/1024/1024).ToString("#,##0"))
Write-Output "Total Time Taken: $((Get-Date).Subtract($startTime).ToString("hh\:mm\:ss"))"