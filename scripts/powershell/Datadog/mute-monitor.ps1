# https://docs.datadoghq.com/monitors/downtimes/examples/?tab=api
# https://github.com/simnyc/poshdog
# $dd_ApiKey = 'put_in_key_here'
# $dd_AppKey = 'put_in_key_here'
# $dd_site = 'put_in_site_here'

# Install the module for your user only 
# Install-Module poshdog -force -Scope CurrentUser

# and import it into your session
Import-Module poshdog
# Get-Command -Module poshdog

Get-Module poshdog | Select-Object Name,Version,Path
$modulePath = (Get-Module poshdog | Select-Object -ExpandProperty Path)
$filePath = Join-Path (Split-Path $modulePath -Parent) "Private/New-DDQuery.ps1"
# Ensure the file exists
if (Test-Path $filePath) {
    # Read the file content, replace the text, and write it back
    (Get-Content -Path $filePath) -replace "datadoghq.com", "datadoghq.eu" | Set-Content -Path $filePath
    Write-Host "Replaced 'datadoghq.com' with 'datadoghq.eu' in $filePath"
} else {
    Write-Host "File not found: $filePath"
}

Set-DDConfiguration -DDApiKey $dd_ApiKey -DDAppKey $dd_AppKey 
Get-DDMonitor


# https://gist.github.com/yogin/39def9303546858878236c72c8301276

curl -X POST "https://api.app.datadoghq.eu/api/v1/downtime" \
-H "Content-type: application/json" \
-H "DD-API-KEY: $dd_ApiKey" \
-H "DD-APPLICATION-KEY: $dd_AppKey" \
-d '{"data":{"type":"downtime","attributes":{"monitor_identifier":{"monitor_tags":["*"]},"scope":"env:prod","display_timezone":"Europe/Berlin","message":"","mute_first_recovery_notification":false,"notify_end_types":["expired","canceled"],"notify_end_states":["alert","warn","no data"],"schedule":{"timezone":"Europe/Berlin","recurrences":[{"start":"2023-07-11T08:00","duration":"2h","rrule":"FREQ=DAILY;INTERVAL=1;BYDAY=2TU"}]}}}'