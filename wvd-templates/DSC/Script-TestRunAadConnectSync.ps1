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

$script = {
    Import-Module AdSync
    Import-Module -Name "C:\Program Files\Microsoft Azure Active Directory Connect\Tools\AdSyncTools"

    $lastRun = Get-ADSyncToolsRunHistory -Days 1 | Where-Object { ($_.Result -eq "Success") -and ($_.RunProfileName -eq "Delta Import") -and (-not($_.ConnectorName -like "*onmicrosoft.com*"))} | Select-Object -First 1
    $secondToLastRun = Get-ADSyncToolsRunHistory -Days 1 | Where-Object { ($_.Result -eq "Success") -and ($_.RunProfileName -eq "Delta Import") -and (-not($_.ConnectorName -like "*onmicrosoft.com*"))} | Select-Object -Skip 1 -First 1
    $timeDifferenceBetweenRuns = New-TimeSpan -Start $secondToLastRun -End $lastRun 
    $syncInterval = (Get-ADSyncScheduler).CurrentlyEffectiveSyncCycleInterval
    return ( $timeDifferenceBetweenRuns -le $syncInterval)
}

$result = Invoke-Command -Session $remoteSession -ScriptBlock $script

return $result