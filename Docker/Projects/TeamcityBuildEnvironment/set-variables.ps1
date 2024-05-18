#The variables required for each application
Write-Host "SETTING VARIABLES"
Write-Host "-----------------------------------------------"
#GLOBAL
$global:host_data_root="e:/project"
Write-Host "GLOBAL"
Write-Host "  data_root                            - $host_data_root"
Write-Host ""

#Servers
$global:gogs_hostname="gogs"
$global:teamcity_hostname="teamcity"
$global:buildagent_hostname="agent"
Write-Host "SERVERS"
Write-Host "  gogs_hostname                        - $gogs_hostname"
Write-Host "  teamcity_hostname                    - $teamcity_hostname"
Write-Host "  buildagent_hostname                       - $buildagent_hostname"
Write-Host ""

#Docker
$global:docker_compose_config_file="docker-compose.yml"
$global:docker_compose_config_file_template="docker-compose.yml.eps"
Write-Host "DOCKER-COMPOSE"
Write-Host "  docker_compose_config_file           - $docker_compose_config_file"
Write-Host "  docker_compose_config_file_template  - $docker_compose_config_file_template"
Write-Host ""

#E:\project\gogs = C:\gogsapp\gogs
#Gogs
$global:gogs_host_data_root         = "$host_data_root/gogs"
$global:gogs_container_data_root    = "c:/gogsapp"
Write-Host "GOGS"
Write-Host "  gogs_host_data_root                  - $gogs_host_data_root"
Write-Host "  gogs_container_data_root             - $gogs_container_data_root"

#E:\project\gogs = C:\gogsapp\gogs
#TeamCity
$global:teamcity_host_install_root      = "$host_data_root/teamcity/install"
$global:teamcity_host_data_root         = "$host_data_root/teamcity/data"
$global:teamcity_container_install_root = "c:/TeamCity"
$global:teamcity_container_data_root    = "C:\ProgramData\JetBrains\TeamCity"
Write-Host "BUILDAGENT"
Write-Host "  teamcity_host_data_root            - $teamcity_host_data_root"
Write-Host "  teamcity_container_install_root    - $teamcity_container_install_root"
Write-Host "  teamcity_container_data_root       - $teamcity_container_data_root"

#E:\project\gogs = C:\gogsapp\gogs
#Buildagent
$global:buildagent_host_data_root         = "$host_data_root/buildagent"
$global:buildagent_container_data_root    = "c:/buildagent"
Write-Host "BUILDAGENT"
Write-Host "  buildagent_host_data_root            - $buildagent_host_data_root"
Write-Host "  buildagent_container_data_root       - $buildagent_container_data_root"
Write-Host "-----------------------------------------------"