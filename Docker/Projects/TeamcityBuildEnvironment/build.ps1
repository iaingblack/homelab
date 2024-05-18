param(
    [Parameter(Mandatory=$false)]
    [boolean]$clean=$true
)
# A prereq to generate our templates in powershell
if (!(Get-Module -ListAvailable -Name "EPS")) { Install-Module -Name EPS -Force }

#Have to set these in local scope or it messes things up. Then fill in details in our templates
. .\set-variables.ps1

#Clean old items and start fresh
if ($clean) {
    if (Test-Path $gogs_host_data_root) { 
        Write-Verbose "CLEANING"
        Remove-Item -Recurse -Force $gogs_host_data_root
    }
    Write-Verbose "Deleting previoud gogs image"
    docker rmi gogs
}

#Create docker compose file
Invoke-EpsTemplate -Path $docker_compose_config_file_template | Out-File $docker_compose_config_file

### GOGS - Create config template and folders for files. Then build container image
Write-Verbose "Gogs data root is           - $gogs_host_data_root"
Write-Verbose "Gogs container data root is - $gogs_container_data_root"

#Create Folders on docker host machine to hold the data. Pre-create the gogs folder so we can map volume before zip extract happens
New-Item $gogs_host_data_root -type directory -Force
New-Item $teamcity_host_install_root -type directory -Force
New-Item $teamcity_host_data_root -type directory -Force

#Build and run container new one
#docker-compose build gogs
#docker-compose up gogs

### TEAMCITY
docker-compose build teamcity
#docker-compose up teamcity

### AGENT
#docker-compose build buildagent
#docker-compose up buildagent

#docker run -d -p 8022:22 -p 3000:3000 -v e:/project/gogs/data/:c:/gogsapp/data/ -v e:/project/gogs/gogs-repositories/:C:/gogsapp/repositories/ -v e:/project/gogs/logs/:C:/gogsapp/logs/ gogs
