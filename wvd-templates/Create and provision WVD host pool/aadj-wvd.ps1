param(
    [Parameter(Mandatory=$true)][string]$RegistrationToken
)

mkdir "C:\wvd" -Force

Write-Host "downloading rd bootloader"
Invoke-WebRequest "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH" -UseBasicParsing -OutFile "C:\wvd\rdbootloader.msi"

Write-Host "downloading rd agent"
Invoke-WebRequest "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv" -UseBasicParsing -OutFile "C:\wvd\rdagent.msi"

Write-Host "files downloaded"

Write-Host "installing rd agent"
Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i C:\wvd\rdagent.msi /qn" -Wait

Write-Host "installing rd bootloader"
Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/i C:\wvd\rdbootloader.msi /qn" -Wait

Stop-Service -Name "RdAgent" -Force
Stop-Service -Name "RDAgentBootLoader" -Force

Write-Host "enabling rd aadj"
New-Item -Path 'HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RDInfraAgent' -Name 'AADJPrivate' -Force

Write-Host "setting rd registration token"
Set-ItemProperty -Path 'HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RDInfraAgent' -Name 'RegistrationToken' -Value $RegistrationToken -Force

Write-Host "restarting rd agent"
Restart-Service -Name "RdAgent" -Force
Restart-Service -Name "RDAgentBootLoader" -Force

Write-Host "disabling NLA"
(Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'").UserAuthenticationRequired
(Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0)

Write-Host "you got a new Cloud PC!"