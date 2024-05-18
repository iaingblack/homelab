$source = "https://dl.gogs.io/0.11.4/windows_amd64.zip"
$destFolder = ".\gogs\Installer"
$destFilename = "windows_amd64.zip"
New-Item -ItemType directory -Path $destFolder -Force
$dest = $destFolder+"\"+$destFilename
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($source,$dest)

$source = "https://github.com/git-for-windows/git/releases/download/v2.13.0.windows.1/Git-2.13.0-64-bit.exe"
$destFolder = ".\gogs\Installer"
$destFilename = "\Git-2.13.0-64-bit.exe"
New-Item -ItemType directory -Path $destFolder -Force
$dest = $destFolder+"\"+$destFilename
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($source,$dest)

