param (
    $tentacle_service_port,
    $octopus_server_certificate_thumbprint
)

$logFolder = 'c:\logs'
$dt=get-date -Format "MM-dd-yyyy_hh-mm-ss"
New-Item -Path $logFolder -ItemType "directory" -Force
Start-Transcript -Path "$($logFolder)\$dt-OctopusInstall.txt"

cd "C:\Program Files\Octopus Deploy\Tentacle"
.\Tentacle.exe create-instance --instance "Tentacle" --config "C:\Octopus\Tentacle.config" --console
.\Tentacle.exe new-certificate --instance "Tentacle" --if-blank --console
.\Tentacle.exe configure --instance "Tentacle" --reset-trust --console
.\Tentacle.exe configure --instance "Tentacle" --home "C:\Octopus" --app "C:\Octopus\Applications" --port "$tentacle_service_port" --console
.\Tentacle.exe configure --instance "Tentacle" --trust "$octopus_server_certificate_thumbprint" --console
netsh advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport="$tentacle_service_port"
.\Tentacle.exe service --instance "Tentacle" --install --start --console

Stop-Transcript