# entrypoint.ps1
param(
    [string]$InstallDir = "C:\Apps\Toy",
    [switch]$FeatureX
)

$markerFile = "C:\AppInstalled.txt"
Write-Host "TinyTest installer running at container startup..." -ForegroundColor Cyan
Write-Host "Install directory: $InstallDir"
Write-Host "FeatureX flag  : $($FeatureX.IsPresent)"

if (Test-Path $markerFile) {
    Write-Host "Marker file found ($markerFile) - installation already completed. Skipping installer." -ForegroundColor Green
}
else {
    $installerPath = "C:\install\TinyTestSetup.exe"

    if (-not (Test-Path $installerPath)) {
        Write-Error "Installer not found at $installerPath"
        exit 1
    }

    $argsList = @("/S", "/DIR=`"$InstallDir`"")

    if ($FeatureX) {
        $argsList += "/FEATUREX"
    }

    Write-Host "Launching installer with args: $($argsList -join ' ')"

    $p = Start-Process -FilePath $installerPath `
                    -ArgumentList $argsList `
                    -Wait -PassThru -NoNewWindow

    if ($p.ExitCode -ne 0) {
        Write-Error "Installer failed with exit code $($p.ExitCode)"
        exit $p.ExitCode
    }

    # Success → create marker so we skip next time
    New-Item -ItemType File -Path $markerFile -Force | Out-Null
    Write-Host "Installation completed. Marker created at $markerFile" -ForegroundColor Green

    Write-Host "Starting dummy long-running process of 2 seconds for testing..."
    Start-Sleep -Seconds 2   # ← dummy placeholder — replace this

    Write-Host "Running an infinite while loop..."
    while ($true) {
        Start-Sleep -Seconds 600   # Repeat
    }
}