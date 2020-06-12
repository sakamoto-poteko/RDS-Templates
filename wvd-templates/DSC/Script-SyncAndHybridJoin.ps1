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
    [string]$fullAadSyncServerName
)

$ScriptPath = [System.IO.Path]::GetDirectoryName($PSCommandPath)

# Dot sourcing Functions.ps1 file
. (Join-Path $ScriptPath "Functions.ps1")

# Setting ErrorActionPreference to stop script execution when error occurs
$ErrorActionPreference = "Stop"

Write-Log -Message 'Script being executed: Attempting to run Azure AD Connect sync'

$remoteSession = New-PSSession -Credential $TenantAdminCredentials -ComputerName $fullAadSyncServerName

Enter-PSSession -Session $remoteSession
    Import-Module AdSync -Force
    $syncStart = Start-AdSyncSyncCylce -PolicyType Delta
    Exit-PSSession
Remove-PSSession $remoteSession

$output = dsregcmd /join

Write-Log -Message "Completed Azure AD Connect synce attempt with result and attempted Hybrid Azure AD Join with result: $output"

return 0