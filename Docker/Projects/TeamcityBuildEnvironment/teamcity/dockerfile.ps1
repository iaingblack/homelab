Write-Verbose "Starting Teamcity"
Set-Location "g:"
Start-Service TeamCity
while ($true) {
	Start-Sleep -Seconds 2
}
