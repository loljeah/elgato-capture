#!/usr/bin/env bash
# List available video and audio capture devices

set -euo pipefail

echo "=== Video Devices (v4l2) ==="
echo ""
for dev in /dev/video*; do
    [ -e "$dev" ] || continue
    echo "$dev:"
    v4l2-ctl --device="$dev" --info 2>/dev/null | grep -E "Card type|Driver name" | sed 's/^/  /'
    echo ""
done

echo "=== Audio Sources (PulseAudio) ==="
echo ""
pactl list sources short 2>/dev/null | while read -r idx name _rest; do
    echo "  $name"
done

echo ""
echo "=== Elgato Detection ==="
if v4l2-ctl --list-devices 2>/dev/null | grep -qi "elgato\|game capture"; then
    echo "  ✓ Elgato device detected"
    v4l2-ctl --list-devices 2>/dev/null | grep -A1 -i "elgato\|game capture"
else
    echo "  ✗ No Elgato device found"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check USB 3.0 connection (blue port)"
    echo "  2. Verify with: lsusb | grep -i elgato"
    echo "  3. Check dmesg: dmesg | tail -20"
fi
