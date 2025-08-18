# Script to create a domain user for Logic Monitor WMI monitoring
# Run as domain admin on a domain controller or machine with AD PowerShell module

# User configuration
$Username = "LogicMonitorUser"  # Change to desired username
$Password = "SecurePassword123!"  # Change to a strong password
$Domain = "YOURDOMAIN"  # Replace with your domain name (e.g., "CONTOSO")
$OUPath = "OU=Users,DC=YOURDOMAIN,DC=com"  # Replace with your OU path
$Description = "Non-admin user for Logic Monitor WMI monitoring"

# Convert password to secure string
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

# Create the domain user
try {
    New-ADUser -SamAccountName $Username `
               -UserPrincipalName "$Username@$Domain.com" `
               -Name $Username `
               -AccountPassword $SecurePassword `
               -Enabled $true `
               -PasswordNeverExpires $true `
               -CannotChangePassword $true `
               -Description $Description `
               -Path $OUPath `
               -ErrorAction Stop
    Write-Host "User $Username created successfully."
}
catch {
    Write-Host "Error creating user: $_"
    exit
}

# Add user to required groups for WMI access
$Groups = @(
    "Distributed COM Users",
    "Performance Monitor Users",
    "Event Log Readers",
    "Remote Management Users"
)

foreach ($Group in $Groups) {
    try {
        Add-ADGroupMember -Identity $Group -Members $Username -ErrorAction Stop
        Write-Host "Added $Username to $Group."
    }
    catch {
        Write-Host "Error adding $Username to $Group: $_"
    }
}

Write-Host "User $Username is ready. Use with Windows_NonAdmin_Config.ps1 on target machines."