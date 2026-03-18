#!/bin/bash
set -e

Xvfb :99 -screen 0 1024x768x16 -nolisten tcp &
XVFB_PID=$!
sleep 2

echo "============================================"
echo "  .NET Framework 4.8 Verification"
echo "============================================"
echo ""

PASS=0
FAIL=0

# --- 1. Registry key check ---
echo "--- Registry Check ---"
REG_KEY='HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'

REG_OUTPUT=$(wine reg query "$REG_KEY" /v Release 2>/dev/null || true)
echo "$REG_OUTPUT"

RELEASE_VAL=$(echo "$REG_OUTPUT" | grep -i "Release" | awk '{print $NF}')

if [ -z "$RELEASE_VAL" ]; then
    echo "FAIL: Registry key not found at $REG_KEY"
    FAIL=$((FAIL + 1))
else
    RELEASE_DEC=$((RELEASE_VAL))
    if [ "$RELEASE_DEC" -ge 528040 ]; then
        echo "PASS: Release = $RELEASE_DEC (>= 528040 means .NET 4.8+)"
        PASS=$((PASS + 1))
    else
        echo "FAIL: Release = $RELEASE_DEC (expected >= 528040 for .NET 4.8)"
        FAIL=$((FAIL + 1))
    fi
fi
echo ""

# --- 2. Version string check ---
echo "--- Version Registry Check ---"
VERSION_OUTPUT=$(wine reg query "$REG_KEY" /v Version 2>/dev/null || true)
VERSION_VAL=$(echo "$VERSION_OUTPUT" | grep -i "Version" | awk '{print $NF}')

if [ -n "$VERSION_VAL" ]; then
    echo "PASS: Version = $VERSION_VAL"
    PASS=$((PASS + 1))
else
    echo "WARN: Version string not found (non-fatal)"
fi
echo ""

# --- 3. File existence checks ---
echo "--- Framework File Checks ---"
FRAMEWORK_DIR="$WINEPREFIX/drive_c/windows/Microsoft.NET/Framework/v4.0.30319"

for f in csc.exe mscorlib.dll clr.dll System.dll System.Core.dll; do
    if [ -f "$FRAMEWORK_DIR/$f" ]; then
        echo "PASS: Found $f"
        PASS=$((PASS + 1))
    else
        echo "FAIL: Missing $f in $FRAMEWORK_DIR"
        FAIL=$((FAIL + 1))
    fi
done
echo ""

# --- Summary ---
echo "============================================"
echo "  Results: $PASS passed, $FAIL failed"
echo "============================================"

wineserver -w 2>/dev/null || true
kill $XVFB_PID 2>/dev/null || true

if [ "$FAIL" -gt 0 ]; then
    echo "VERIFICATION FAILED"
    exit 1
fi

echo ".NET Framework 4.8 verified successfully."
exit 0
