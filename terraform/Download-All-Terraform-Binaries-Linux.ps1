# Define the base URL for Terraform releases
$baseUrl = "https://releases.hashicorp.com/terraform"
$outputDir = "/root/terraform-binaries" # Change this to your desired directory

# Create the output directory if it doesn't exist
if (-Not (Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir
}

# Get the list of available versions
# Get the list of available versions
$versionsPage = Invoke-WebRequest -Uri $baseUrl
$versionLinks = ($versionsPage.Links | Where-Object { $_.href -match "terraform/\d+\.\d+\.\d+/$" }).href

# Filter out pre-release versions (beta, rc, etc.)
$releasedVersions = @()
foreach ($versionLink in $versionLinks) {
    $version = $versionLink -replace "terraform/", "" -replace "/$", ""
    if ($version -notmatch "(beta|rc|alpha|pre)") {
        $releasedVersions += $version
    }
}

# Output the released versions
$releasedVersions = $releasedVersions | Sort-Object
$releasedVersions = $releasedVersions | ForEach-Object { $_.Substring(1) }
# Remove 0.x.x versions
$releasedVersions = $releasedVersions | Where-Object { $_ -notmatch "^0\." }

# Create Download Links
foreach ($releasedVersion in $releasedVersions) {
    if (Test-Path $outputDir\$releasedVersion\terraform.exe) {
        Write-Output "Terraform $outputDir\$releasedVersion\terraform.exe Exists"
    }
    else {
        Write-Output "Terraform $outputDir\$releasedVersion Does Not Exist"
        $downloadUrl = "$baseURL/$releasedVersion/terraform_${releasedVersion}_linux_amd64.zip"
        $downloadUrl
        $response = Invoke-WebRequest -Uri $downloadUrl -Method Head -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            $zipFilePath = "$outputDir\terraform_${releasedVersion}_linux_amd64.zip"
            $extractPath = "$outputDir\$releasedVersion"

            Write-Output "Downloading Terraform $releasedVersion..."
            Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFilePath

            Write-Output "Unzipping Terraform $releasedVersion..."
            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath

            # Remove the zip file after extraction
            Remove-Item -Path $zipFilePath
        } else {
            Write-Output "$releasedVersion not Found..."
        }
    }
}

Write-Output "All Terraform versions have been downloaded and unzipped."
