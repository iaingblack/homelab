# print-values.ps1
param(
    [string]$Name = "Unknown",  # Default value if not provided
    [string]$Age = "N/A",
    [string]$Location = "N/A"
)

Write-Host "Starting up with provided values..."
Write-Host "Name: $Name"
Write-Host "Age: $Age"
Write-Host "Location: $Location"
Write-Host "Boot complete!"