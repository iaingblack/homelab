Write-Host "Stopping Containers"
.\stop-all-containers.ps1
Write-Host "Removing Containers"
.\remove-all-containers.ps1
Write-Host "Deleting Images"
.\remove-dangling-images.ps1
