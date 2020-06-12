param(
    [Parameter(mandatory = $true)]
    [pscredential]$TenantAdminCredentials,

    [Parameter(mandatory = $true)]
    [string]$fullAadSyncServerName
)

$ScriptPath = [System.IO.Path]::GetDirectoryName($PSCommandPath)

# Dot sourcing Functions.ps1 file
. (Join-Path $ScriptPath "Functions.ps1")

# Setting ErrorActionPreference to stop script execution when error occurs
$ErrorActionPreference = "Stop"

write-log -message 'Script being executed: Attempting to run Azure AD Connect sync'

$remoteSession = New-PSSession -Credential $TenantAdminCredentials -ComputerName <AADConnectSyncMachineName>

$result = null

Enter-PSSession $remoteSession

Import-Module AdSync
Import-module -Name "C:\Program Files\Microsoft Azure Active Directory Connect\Tools\AdSyncTools"

$lastRun = Get-ADSyncToolsRunHistory -Days 1 | Where-Object { ($_.Result -eq "Success") -and ($_.RunProfileName -eq "Export") -and ($_.ConnectorName -like "*onmicrosoft.com*" )} | Select-Object -First 1
$secondToLastRun = Get-ADSyncToolsRunHistory -Days 1 | Where-Object { ($_.Result -eq "Success") -and ($_.RunProfileName -eq "Export") -and ($_.ConnectorName -like "*onmicrosoft.com*" )} | Select-Object -skip 1 -First 1
# or DeltaImport
$currentTimeSpan = New-TimeSpan -Start $lastRunTime -End $currentTime 
$syncInterval = (Get-ADSyncScheduler).CurrentlyEffectiveSyncCycleInterval

Exit-PSSession
Remove-PSSession $remoteSession