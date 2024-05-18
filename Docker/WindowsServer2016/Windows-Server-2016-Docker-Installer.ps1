# https://blog.docker.com/2016/09/build-your-first-docker-windows-server-container/
# https://msdn.microsoft.com/en-gb/virtualization/windowscontainers/docker/configure_docker_daemon
# Add the containers feature and restart
Install-WindowsFeature containers
# Change this if required - HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa\FipsAlgorithmPolicy\Enabled to 0
Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\FipsAlgorithmPolicy\ -Name Enabled -Value 0
Restart-Computer -Force

#--------------------------------------------------------------------
# NEW WAY (If this fails remember to turn off FIPS compliance
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name DockerMsftProvider -Force

# If issues do this - https://github.com/OneGet/MicrosoftDockerProvider/issues/15#issuecomment-269219021
# https://dockermsft.blob.core.windows.net/dockercontainer/docker-17-03-1-ee.zip
# https://dockermsft.blob.core.windows.net/dockercontainer/DockerMsftIndex.json 
Install-Package -Name docker -ProviderName DockerMsftProvider -Force

#--------------------------------------------------------------------
# OLD WAY
# Download, install and configure Docker Engine
$version = (Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/docker/docker/master/VERSION).Content.Trim()
Invoke-WebRequest "https://master.dockerproject.org/windows/amd64/docker-$($version).zip" -OutFile "$env:TEMP\docker.zip" -UseBasicParsing

Expand-Archive -Path "$env:TEMP\docker.zip" -DestinationPath $env:ProgramFiles

# For quick use, does not require shell to be restarted.
$env:path += ";c:\program files\docker"

# For persistent use, will apply even after a reboot. 
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Docker", [EnvironmentVariableTarget]::Machine)

# Open firewall port 2375
netsh advfirewall firewall add rule name="docker engine" dir=in action=allow protocol=TCP localport=2375

#------------------------------------------------------------------
#CHOOSE ONE

# Start a new PowerShell prompt before proceeding
dockerd --register-service

# Configure Docker daemon to listen on both pipe and TCP (replaces docker --register-service invocation above)
dockerd.exe -H npipe:////./pipe/docker_engine -H 0.0.0.0:2375 --register-service

#Then
Start-Service docker

#If you have it registred already and can't re-register, exit powerhsell and type this
sc delete docker


#--------------------------------------------------------------------
#To set proxy do this in powershell
[Environment]::SetEnvironmentVariable("HTTP_PROXY", "http://username:password@proxy:port/", [EnvironmentVariableTarget]::Machine)

#--------------------------------------------------------------------
#Install docker compose
Invoke-WebRequest https://dl.bintray.com/docker-compose/master/docker-compose-Windows-x86_64.exe -UseBasicParsing -OutFile $env:ProgramFiles\docker\docker-compose.exe

