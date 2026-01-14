
wsl --update

Download this and install: https://nsis.sourceforge.io/Download

```powershell
cd Docker\WindowsApps
& 'C:\Program Files (x86)\NSIS\Bin\makensis.exe' testinst.nsi
```

Then try an 'install'

```powershell
# Normal (shows GUI)
.\TinyTestSetup.exe

# Silent + custom install dir
.\TinyTestSetup.exe /S /DIR="C:\Custom\ToyApp"

# Silent + custom dir + feature flag
.\TinyTestSetup.exe /S /DIR="D:\Apps\Toy" /FEATUREX

# Just change folder (shows GUI)
.\TinyTestSetup.exe /DIR="C:\Program Files\MyToyApp"

# If you added /? support in the installer:
.\TinyTestSetup.exe /?
```


# Docker Build

```powershell
# Build
docker build -t test-installer-runtime .

# 1. Use defaults from CMD
docker run --name testapp --rm test-installer-runtime 

# 2. Custom dir + feature flag
docker run --name testapp --rm test-installer-runtime -InstallDir "C:\MyApp" -FeatureX

# 3. Custom dir only (no feature)
docker run --name testapp --rm test-installer-runtime -InstallDir "C:\Tools\Demo"

# 4. Interactive shell instead — to inspect after install
docker exec -it testapp powershell
```