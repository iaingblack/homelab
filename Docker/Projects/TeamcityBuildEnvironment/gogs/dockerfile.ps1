
if (!(Test-Path c:/gogsapp/gogs/gogs.exe)) {
    Write-Verbose "No Existing installation. Please complete setup. Unzipping Gogs to Folder - c:/gogsapp/"
    Expand-Archive -Path C:\Installer\windows_amd64.zip -DestinationPath c:/gogsapp
    Write-Verbose "Please go to http://gogs:3000 to setup"
}
else {
    Write-Verbose "Found existing installation. Running that"
}

Write-Verbose "Starting GOGS"
Set-Location "g:"
.\gogs.exe web