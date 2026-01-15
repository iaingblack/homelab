# Dockerfile
FROM mcr.microsoft.com/windows/server:ltsc2022

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Optional: pre-create target folder(s) if desired
RUN New-Item -ItemType Directory -Path C:\Apps -Force | Out-Null

# Copy the script into the container
COPY print-values.ps1 c:/Apps/print-values.ps1

# Set the entrypoint. The params get passed magically
ENTRYPOINT ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass", "-File",  "c:/Apps/print-values.ps1"]