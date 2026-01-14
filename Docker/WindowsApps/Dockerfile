# escape=`

# INSTALLS ON CONTAINER FIRST START - EXE BAKED IN

FROM mcr.microsoft.com/windows/server:ltsc2022

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Working directory for installer + script
WORKDIR /install

# Copy both files
COPY TinyTestSetup.exe .
COPY Install-TinyTest.ps1    .

# Optional: pre-create target folder(s) if desired
RUN New-Item -ItemType Directory -Path C:\Apps -Force | Out-Null

# ENTRYPOINT runs the script every container start
ENTRYPOINT ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass", "-File", "C:\\install\\Install-TinyTest.ps1"]

# Default parameters (can be overridden at docker run)
CMD ["-InstallDir", "C:\\Custom\\ToyApp", "-FeatureX"]