netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985
netsh advfirewall firewall add rule name="WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986

winrm quickconfig -q
winrm set winrm/config/service '@{AllowUnencrypted="false"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'

Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $false -Force
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true -Force