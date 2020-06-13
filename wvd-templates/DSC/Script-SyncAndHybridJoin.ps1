<#

.SYNOPSIS
add an instance to hostpool.

.DESCRIPTION
This script will add an instance to existing hostpool.
The supported Operating Systems Windows Server 2016/windows 10 multisession.

.ROLE
Readers

#>
param(
    [Parameter(mandatory = $true)]
    [pscredential]$TenantAdminCredentials,

    [Parameter(mandatory = $true)]
    [string]$FullAadSyncServerName
)

$ScriptPath = [System.IO.Path]::GetDirectoryName($PSCommandPath)

# Dot sourcing Functions.ps1 file
. (Join-Path $ScriptPath "Functions.ps1")

# Setting ErrorActionPreference to stop script execution when error occurs
$ErrorActionPreference = "Stop"

Write-Log -Message 'Script being executed: Attempting to run Azure AD Connect sync'

$remoteSession = New-PSSession -Credential $TenantAdminCredentials -ComputerName $FullAadSyncServerName

$script = {
    Import-Module AdSync -Force
    
    while ($scheduler.SyncCycleInProgress){
        Start-Sleep -Seconds 30
    }

    $value = Start-AdSyncSyncCycle -PolicyType Delta

    while ($scheduler.SyncCycleInProgress){
        Start-Sleep -Seconds 30
    }
    
    return $value
}

$triggeredSync = Invoke-Command -Session $remoteSession -ScriptBlock $script
if ($triggeredSync) {
    dsregcmd /join
    Write-Log -Message "Completed Azure AD Connect synce attempt with result and attempted Hybrid Azure AD Join."
}
else {
    Write-Log -Message "Did not trigger Azure AD Connect sync or Hybrid Azure AD Join since there is a sync already in progress."
}