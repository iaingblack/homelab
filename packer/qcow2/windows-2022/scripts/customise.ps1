Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Seems to cause a non-zero exit code and breaks the build...
# choco install virtio-drivers -y
$url  = 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win-guest-tools.exe'
$dest = 'c:\virtio-win-guest-tools.exe'
Invoke-WebRequest -Uri $url -OutFile $dest
c:\virtio-win-guest-tools.exe -s
