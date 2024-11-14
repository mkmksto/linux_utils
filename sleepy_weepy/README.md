# Sleepy Weepy

A simple daemon that automatically puts your laptop to sleep at a specified time every day.

## Features

- Schedule automatic sleep time (0-24 hours format)
- Customizable notification message before sleep
- Optional sound alert before sleep
- Runs as a system service
- Configurable through a simple configuration file

## Requirements

- Linux system with systemd
- notify-send (usually part of libnotify-bin package)
- For sound support: PulseAudio (paplay) or ALSA (aplay)

## Quick Installation

For a quick installation, simply run:

```bash
sudo ./install.sh
```

This script will:

- Check for existing installations
- Install required packages
- Set up all necessary files and directories
- Create and start the service

## Updating

To update an existing installation:

```bash
sudo ./update.sh
```

This script will:

- Backup your current configuration
- Update all necessary files
- Restart the service
- Preserve your settings

## Uninstalling

To completely remove Sleepy Weepy:

```bash
sudo ./uninstall.sh
```

This script will:

- Stop and disable the service
- Remove all installed files
- Clean up the system

## Configuration

The configuration file is located at `/etc/sleepy_weepy/config.conf`. The daemon will create a default configuration file if it doesn't exist.

To modify the settings:

```bash
sudo vi /etc/sleepy_weepy/config.conf
```

Configuration options:

```bash
# Sleep hour (0-23)
SLEEP_HOUR=21

# Notification message (optional)
MESSAGE="Sleepy Weepy is going to sleep now"

# Sound file path (optional, leave empty to use default sound)
SOUND_FILE=""
# Default sound file path
# SOUND_FILE="/usr/local/share/sleepy_weepy/sleepy_weepy_alarmey.wav"
```

After modifying the configuration, restart the service:

```bash
sudo systemctl restart sleepy_weepy.service
```

## Verifying the Service

Check if the service is running:

```bash
sudo systemctl status sleepy_weepy.service
```

View the logs:

```bash
sudo journalctl -u sleepy_weepy.service
```

## Troubleshooting

1. If notifications don't work:

   - Ensure libnotify-bin is installed
   - Check if the DISPLAY variable is set correctly
   - Verify the user has proper permissions

2. If sound doesn't play:

   - Ensure PulseAudio or ALSA is installed
   - Verify the sound file path is correct
   - Check if the file format is supported

3. If the service fails to start:
   - Check the logs: `sudo journalctl -u sleepy_weepy.service`
   - Verify the script has execute permissions
   - Ensure the configuration file is readable
