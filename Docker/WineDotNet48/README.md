# Wine + .NET Framework 4.8 Docker Image

A Docker image based on Ubuntu 22.04 that runs Wine with .NET Framework 4.8
installed and verified. Useful as a base image for running .NET Framework
applications on Linux.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running

## Build

```bash
docker build -t wine-dotnet48 .
```

The build takes **20-40 minutes** depending on your internet speed and hardware.
Most of that time is `winetricks` downloading and installing .NET prerequisites
(dotnet20, dotnet40, dotnet48). A verification step runs automatically at the
end of the build -- if it passes, .NET 4.8 is confirmed installed.

To rebuild from scratch (no cache):

```bash
docker build --no-cache -t wine-dotnet48 .
```

## Run

### Interactive shell

Drop into a bash shell inside the container:

```bash
docker run --rm -it wine-dotnet48 bash
```

From inside the container you need to start Xvfb before running any Wine
commands, since Wine requires a display:

```bash
Xvfb :99 -screen 0 1024x768x16 -nolisten tcp &
sleep 1
```

Then you can run Wine commands:

```bash
# Check Wine version
wine --version

# Launch a Windows command prompt
wine cmd

# Query the .NET 4.8 registry key
wine reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Release

# List the .NET Framework directory
ls $WINEPREFIX/drive_c/windows/Microsoft.NET/Framework/v4.0.30319/

# Compile and run a C# file (see example below)
wine $WINEPREFIX/drive_c/windows/Microsoft.NET/Framework/v4.0.30319/csc.exe /out:C:\\hello.exe C:\\hello.cs
wine C:\\hello.exe
```

### Run verification again

```bash
docker run --rm wine-dotnet48 bash -c "/verify-dotnet.sh"
```

### Run a .NET executable directly

Mount your exe into the container and run it:

```bash
docker run --rm -v "$(pwd)/myapp:/app" wine-dotnet48 bash -c "\
    Xvfb :99 -screen 0 1024x768x16 -nolisten tcp & sleep 1 && \
    wine /app/MyApp.exe"
```

## Example: compile and run C# inside the container

```bash
docker run --rm -it wine-dotnet48 bash
```

Then inside the container:

```bash
Xvfb :99 -screen 0 1024x768x16 -nolisten tcp &
sleep 1

cat > /root/.wine/drive_c/hello.cs << 'EOF'
using System;
class Program {
    static void Main() {
        Console.WriteLine("Hello from .NET " +
            Environment.Version + " on Wine/Linux!");
    }
}
EOF

wine /root/.wine/drive_c/windows/Microsoft.NET/Framework/v4.0.30319/csc.exe \
    /out:C:\\hello.exe C:\\hello.cs

wine C:\\hello.exe
```

## File overview

| File | Purpose |
|---|---|
| `Dockerfile` | Main build file -- Ubuntu 22.04 + WineHQ + winetricks + .NET 4.8 |
| `install-dotnet.sh` | Manages Xvfb, wineboot init, xdotool auto-clicker, and `winetricks -q dotnet48` |
| `verify-dotnet.sh` | Runs at build time to confirm .NET 4.8 via registry keys and file checks |
| `Dockerfile.scottyhardy` | Alternative build using `scottyhardy/docker-wine` as base (with retry loop) |

## Environment variables

These are set in the Dockerfile and persist into running containers:

| Variable | Value | Purpose |
|---|---|---|
| `WINEARCH` | `win32` | 32-bit Wine prefix (most reliable for .NET 4.8) |
| `WINEPREFIX` | `/root/.wine` | Wine configuration/install directory |
| `DISPLAY` | `:99` | X display number (must start Xvfb on this display) |
| `WINEDEBUG` | `-all` | Suppress all Wine debug output |

## Troubleshooting

**Build hangs at `wineboot --init`**: The install script uses `timeout 120` so
it will continue after 2 minutes even if wineboot gets stuck. If the build
still hangs, cancel and retry.

**Build hangs at `winetricks -q dotnet48`**: The xdotool auto-clicker should
dismiss any dialog boxes. If it still hangs, try the `Dockerfile.scottyhardy`
variant which includes a retry loop.

**`wine` commands fail with "no display" errors**: You need to start Xvfb first
when running interactively. See the instructions above.

**.NET executables crash or don't run**: Make sure you're using the 32-bit
framework path (`Framework/v4.0.30319`, not `Framework64`), since the prefix
is `win32`.
