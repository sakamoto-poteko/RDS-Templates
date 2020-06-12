<#

.SYNOPSIS
Test if machine is successfuly Hybrid Azure AD joined.

.DESCRIPTION
The supported Operating Systems Windows Server 2016.

.ROLE
Readers

#>


$ScriptPath = [System.IO.Path]::GetDirectoryName($PSCommandPath)

# Dot sourcing Functions.ps1 file
. (Join-Path $ScriptPath "Functions.ps1")

# Setting ErrorActionPreference to stop script execution when error occurs
$ErrorActionPreference = "Stop"

write-log -message 'Script being executed: Test if machine is hybrid Azure AD Joined'

$output = dsregcmd /status
$isAzureAdJoined = ($output | Select-String -Pattern "AzureAdJoined :") -split ' ' -contains "YES"
$isDomainJoined = ($output | Select-String -Pattern "DomainJoined :") -split ' ' -contains "YES"

return ($isAzureAdJoined -and $isDomainJoined)