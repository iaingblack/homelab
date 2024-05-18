$dest = "C:\Windows\Temp\puppet.msi"

if (-Not (Test-Path $dest)) {
  $WebClient = New-Object System.Net.WebClient
  $catchexitcode = if ([System.IntPtr]::Size -eq 8) { $source = "http://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi" }
  $catchexitcode = if ([System.IntPtr]::Size -eq 4) { $source = "http://downloads.puppetlabs.com/windows/puppet-agent-x86-latest.msi" }
  Write-Host "Downloading Puppet Installer"
  $WebClient.DownloadFile($source,$dest)
}

Write-Host "Installing Puppet"
cmd /c "msiexec /qn /norestart /i $dest"