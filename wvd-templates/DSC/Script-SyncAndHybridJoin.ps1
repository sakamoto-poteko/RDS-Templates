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
        Start-Sleep -Seconds 90
    }
}

Invoke-Command -Session $remoteSession -ScriptBlock $script

while ( -not(isHybridAadJoined)) {
    Write-Log -Message "[SyncAndHybridJoin] Not Hybrid Azure AD Joined. Calling PerformHybridAadJoin to perform the Hybrid Azure AD Join."
    PerformHybridAadJoin
    Start-Sleep -Seconds 20
}

# Run the auto-enroll command for MDM
# cmd %windir%\system32\deviceenroller.exe /c /AutoEnrollMDM