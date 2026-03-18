#!/bin/bash
set -ex

Xvfb :99 -screen 0 1024x768x16 -nolisten tcp &
XVFB_PID=$!
sleep 2

# Auto-dismiss any GUI dialogs that .NET installers pop up under Wine.
# Even with winetricks -q, some installers show modal dialogs that block
# until a button is clicked. This loop presses Enter every 3 seconds.
(
    while true; do
        xdotool key --clearmodifiers Return 2>/dev/null || true
        sleep 3
    done
) &
CLICKER_PID=$!

# wineboot --init typically times out in Docker due to missing services -- that's expected
timeout 120 wineboot --init || echo "wineboot init timed out (expected in Docker, continuing...)"
timeout 30 wineserver -w || echo "wineserver wait timed out (continuing...)"

winetricks -q dotnet48

wineserver -w

kill $CLICKER_PID 2>/dev/null || true
kill $XVFB_PID 2>/dev/null || true
