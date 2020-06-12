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

Write-log -Message 'Script being executed: Test if machine is hybrid Azure AD Joined'

$output = dsregcmd /status
$isAzureAdJoined = ($output | Select-String -Pattern "AzureAdJoined :") -split ' ' -contains "YES"
$isDomainJoined = ($output | Select-String -Pattern "DomainJoined :") -split ' ' -contains "YES"

$result = ($isAzureAdJoined -and $isDomainJoined)

Write-Log -Message "DomainJoined: $isDomainJoined. AzureAdJoined: $isAzureAdJoined. Hybrid Azure AD Joined: $result"
return $result