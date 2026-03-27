#!/usr/bin/env bash
# Simple Elgato HD60 S capture window for Discord streaming
#
# Usage: ./capture.sh [video_device] [audio_device]
#
# Examples:
#   ./capture.sh                           # Auto-detect
#   ./capture.sh /dev/video0               # Specific video device
#   ./capture.sh /dev/video0 hw:2,0        # Specific video + audio

set -euo pipefail

# --- Configuration ---
VIDEO_DEVICE="${1:-}"
AUDIO_DEVICE="${2:-}"

# Resolution/framerate (HD60 S supports up to 1080p60)
WIDTH=1920
HEIGHT=1080
FPS=60

# --- Auto-detect video device ---
if [[ -z "$VIDEO_DEVICE" ]]; then
    # Find Elgato device
    VIDEO_DEVICE=$(v4l2-ctl --list-devices 2>/dev/null | \
        grep -A1 -i "elgato\|game capture" | \
        grep "/dev/video" | \
        head -1 | \
        tr -d '[:space:]') || true

    if [[ -z "$VIDEO_DEVICE" ]]; then
        echo "Error: No Elgato device found. Run ./list-devices.sh to check."
        exit 1
    fi
fi

echo "Video device: $VIDEO_DEVICE"

# --- Auto-detect audio device ---
if [[ -z "$AUDIO_DEVICE" ]]; then
    # Try to find Elgato audio via PulseAudio
    AUDIO_DEVICE=$(pactl list sources short 2>/dev/null | \
        grep -i "elgato\|game_capture" | \
        awk '{print $2}' | \
        head -1) || true

    if [[ -n "$AUDIO_DEVICE" ]]; then
        echo "Audio device: $AUDIO_DEVICE (PulseAudio)"
        AUDIO_OPTS="--audio-device=pulse/$AUDIO_DEVICE"
    else
        echo "Audio: Using default (Elgato audio not found in PulseAudio)"
        AUDIO_OPTS=""
    fi
else
    echo "Audio device: $AUDIO_DEVICE"
    if [[ "$AUDIO_DEVICE" == hw:* ]]; then
        AUDIO_OPTS="--audio-device=alsa/$AUDIO_DEVICE"
    else
        AUDIO_OPTS="--audio-device=pulse/$AUDIO_DEVICE"
    fi
fi

# --- Query actual resolution from device ---
ACTUAL_RES=$(v4l2-ctl -d "$VIDEO_DEVICE" --get-fmt-video 2>/dev/null | \
    grep "Width/Height" | \
    sed 's/.*: //' | \
    tr -d '[:space:]') || true

if [[ -n "$ACTUAL_RES" ]]; then
    echo "Resolution: $ACTUAL_RES (from device)"
else
    echo "Resolution: auto"
fi

# --- Launch mpv ---
echo ""
echo "Starting capture... (press 'q' to quit)"
echo "Window title: 'Elgato Capture' — share this in Discord"
echo ""

exec mpv \
    --title="Elgato Capture" \
    --profile=low-latency \
    --untimed \
    --no-cache \
    --demuxer-lavf-format=v4l2 \
    $AUDIO_OPTS \
    "$VIDEO_DEVICE"
