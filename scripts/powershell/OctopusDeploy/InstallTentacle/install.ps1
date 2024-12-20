psexec \\192.168.1.239 -u domain\username -p password powershell -NoProfile -Command "Invoke-WebRequest 'https://download.octopusdeploy.com/octopus/Octopus.Tentacle.x64.msi' -OutFile 'C:\Temp\Octopus.Tentacle.x64.msi'"

psexec \\192.168.1.239 -u domain\username -p password msiexec /i "C:\Temp\Octopus.Tentacle.x64.msi" /quiet /norestart


