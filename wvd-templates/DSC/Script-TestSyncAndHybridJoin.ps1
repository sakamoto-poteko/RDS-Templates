param(
    [Parameter(mandatory = $true)]
    [pscredential]$TenantAdminCredentials,

    [Parameter(mandatory = $true)]
    [string]$fullAadSyncServerName
)

$ScriptPath = [System.IO.Path]::GetDirectoryName($PSCommandPath)

# Dot sourcing Functions.ps1 file
. (Join-Path $ScriptPath "Functions.ps1")
Write-Log -message "About to set ErrorActionPreference"

# Setting ErrorActionPreference to stop script execution when error occurs
$ErrorActionPreference = "Stop"

Write-Log -Message 'Script being executed: Attempting to see if device is already Hybrid Azure AD Joined.'

$output = dsregcmd /status
$isAzureAdJoined = ($output | Select-String -Pattern "AzureAdJoined :") -split ' ' -contains "YES"
$isDomainJoined = ($output | Select-String -Pattern "DomainJoined :") -split ' ' -contains "YES"

$result = ($isAzureAdJoined -and $isDomainJoined)

Write-Log -Message "DomainJoined: $isDomainJoined. AzureAdJoined: $isAzureAdJoined. Hybrid Azure AD Joined: $result."

return $result