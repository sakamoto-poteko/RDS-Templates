<#

.SYNOPSIS
add an instance to hostpool.

.DESCRIPTION
This script will add an instance to existing hostpool.
The supported Operating Systems Windows Server 2016/windows 10 multisession.

.ROLE
Readers

#>
$ScriptPath = [System.IO.Path]::GetDirectoryName($PSCommandPath)

# Dot sourcing Functions.ps1 file
. (Join-Path $ScriptPath "Functions.ps1")

# Setting ErrorActionPreference to stop script execution when error occurs
$ErrorActionPreference = "Stop"

Write-Log -message 'Script being executed: Attempting to perform Hybrid Azure AD Join'

$output = dsregcmd /join

Write-Log -Message "Attempt at Hybrid Azure AD Join operation: $output"

# Run the auto-enroll command for MDM
cmd %windir%\system32\deviceenroller.exe /c /AutoEnrollMDM