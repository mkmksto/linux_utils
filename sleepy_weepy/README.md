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

## Installation

1. Install required packages:

```bash
sudo apt-get update
sudo apt-get install libnotify-bin pulseaudio
```

2. Create the daemon script:

```bash
sudo mkdir -p /usr/local/bin
sudo cp sleepy_weepy.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/sleepy_weepy.sh
```

3. Create a systemd service file:

```bash
sudo vi /etc/systemd/system/sleepy_weepy.service
```

4. Add the following content to the service file:

```bash
[Unit]
Description=Sleepy Weepy Daemon
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/sleepy_weepy.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
```

5. Enable and start the service:

```bash
sudo systemctl enable sleepy_weepy.service
sudo systemctl start sleepy_weepy.service
```

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

# Sound file path (optional)
SOUND_FILE="/path/to/your/sound.mp3"
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

## Uninstallation

To remove Sleepy Weepy:

```bash
sudo systemctl stop sleepy_weepy.service
sudo systemctl disable sleepy_weepy.service
sudo rm /etc/systemd/system/sleepy_weepy.service
sudo rm /usr/local/bin/sleepy_weepy.sh
sudo rm -r /etc/sleepy_weepy
```
