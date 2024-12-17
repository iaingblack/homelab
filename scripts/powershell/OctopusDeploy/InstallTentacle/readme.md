https://learn.microsoft.com/en-us/sysinternals/downloads/psexec

unzip and copy to c:\windows\system32

psexec \\192.168.1.115 -u nuc-winserver\administrator -p Password1! powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = 'tls12'; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"


choco source remove -n=chocolateys
choco source add -n=nexus -s=http://192.168.1.239:8081/repository/chocolatey-group/
choco install octopusdeploy.tentacle.selfcontained 
