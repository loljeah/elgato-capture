# Elgato Capture

Simple video capture window for Elgato HD60 S/S+ on NixOS. Opens a low-latency mpv window you can share directly to Discord.

## Quick Start

```bash
nix-shell
./list-devices.sh   # verify card is detected
./capture.sh        # start capture window
```

Then in Discord: Share Screen → select "Elgato Capture" window.

## Requirements

- Elgato HD60 S or S+ connected via USB 3.0
- HDMI source connected to the capture card

## Troubleshooting

### Card not detected

```bash
lsusb | grep -i elgato
dmesg | grep -i elgato
```

The HD60 S should appear as USB device `0fd9:0066` or similar.

### No video / black screen

1. Check HDMI source is outputting (try different cable)
2. Some sources have HDCP — disable if possible
3. Try different input format:
   ```bash
   v4l2-ctl -d /dev/video0 --list-formats-ext
   ```

### Audio issues

List available audio sources:
```bash
pactl list sources short
```

Specify audio device manually:
```bash
./capture.sh /dev/video0 alsa_input.usb-Elgato...
```

## Manual mpv command

If the script doesn't work, try raw mpv:

```bash
mpv --profile=low-latency av://v4l2:/dev/video0
```
