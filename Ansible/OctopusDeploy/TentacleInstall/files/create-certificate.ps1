param (
    $tentacle_service_port,
    $octopus_server_certificate_thumbprint
)

$logFolder = 'c:\logs'
$dt=get-date -Format "MM-dd-yyyy_hh-mm-ss"
New-Item -Path $logFolder -ItemType "directory" -Force
Start-Transcript -Path "$($logFolder)\$dt-OctopusInstall.txt"
cd "C:\Program Files\Octopus Deploy\Tentacle"
.\Tentacle.exe new-certificate --instance "Tentacle" --if-blank --console
Stop-Transcript