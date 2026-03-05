# Razer Leviathan Volume Sync on CachyOS

A solution to sync PipeWire/PulseAudio volume controls with the Razer Leviathan V2 X hardware master volume.

## Problem

The Razer Leviathan V2 X doesn't properly respond to per-channel volume changes (PCM,0 / numid=3) from the desktop audio slider. This script bridges that gap by mirroring the software volume slider to the working hardware master register (PCM,1 / numid=4).

## Solution

This project provides:
- A bash script that monitors PipeWire/PulseAudio sink volume changes
- A systemd user service to run the script automatically on startup
- Volume changes are instantly synchronized to the device's hardware master control

## Installation

### 1. Install the script
```bash
mkdir -p ~/.local/bin
cp razer-leviathan-vol-sync.sh ~/.local/bin/
chmod +x ~/.local/bin/razer-leviathan-vol-sync.sh
```

### 2. Install the systemd service
```bash
mkdir -p ~/.config/systemd/user
cp razer-leviathan-vol-sync.service ~/.config/systemd/user/
```

### 3. Enable and start the service
```bash
systemctl --user daemon-reload
systemctl --user enable razer-leviathan-vol-sync
systemctl --user start razer-leviathan-vol-sync
```

### 4. Verify it's running
```bash
systemctl --user status razer-leviathan-vol-sync
```

## How It Works

1. The script waits for PipeWire to be ready
2. It waits for the Razer Leviathan sink to appear
3. On startup, it applies the current slider position to the hardware master
4. It subscribes to volume change events via `pactl`
5. When a sink change is detected, it reads the new volume percentage and maps it to the hardware master control

## Requirements

- Linux with PipeWire or PulseAudio
- ALSA (for `amixer` command)
- Razer Leviathan V2 X connected to the system
- User must have permission to access ALSA controls (may need to adjust device permissions or add user to `audio` group)

## Troubleshooting

### Script not syncing volume
Check the service status:
```bash
journalctl --user -u razer-leviathan-vol-sync -f
```

### Permission denied
Add your user to the audio group:
```bash
sudo usermod -a -G audio $USER
```
Then log out and back in.

### Can't find the device
Verify the Razer Leviathan is detected:
```bash
grep "Razer Leviathan" /proc/asound/cards
```

## License

MIT
# main
