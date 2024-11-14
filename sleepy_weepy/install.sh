#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root${NC}"
    exit 1
fi

# Check if service already exists
if systemctl is-active --quiet sleepy_weepy.service; then
    echo -e "${RED}Sleepy Weepy is already installed and running.${NC}"
    echo "Please use update.sh to update or uninstall.sh to remove first."
    exit 1
fi

# Check if any files exist
if [ -f "/usr/local/bin/sleepy_weepy.sh" ] || \
   [ -d "/usr/local/share/sleepy_weepy" ] || \
   [ -f "/etc/systemd/system/sleepy_weepy.service" ] || \
   [ -d "/etc/sleepy_weepy" ]; then
    echo -e "${RED}Found existing Sleepy Weepy files.${NC}"
    echo "Please use uninstall.sh to remove them first, or you may want to update instead."
    exit 1
fi

echo -e "${YELLOW}Installing required packages...${NC}"
apt update
apt install -y libnotify-bin pulseaudio

echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p /usr/local/bin
mkdir -p /usr/local/share/sleepy_weepy
mkdir -p /etc/sleepy_weepy

echo -e "${YELLOW}Copying files...${NC}"
cp sleepy_weepy.sh /usr/local/bin/
cp sleepy-weepy-status /usr/local/bin/
cp sleepy_weepy_alarmey.wav /usr/local/share/sleepy_weepy/
chmod +x /usr/local/bin/sleepy_weepy.sh
chmod +x /usr/local/bin/sleepy-weepy-status

echo -e "${YELLOW}Creating service file...${NC}"
cat > /etc/systemd/system/sleepy_weepy.service << EOL
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
EOL

echo -e "${YELLOW}Enabling and starting service...${NC}"
systemctl daemon-reload
systemctl enable sleepy_weepy.service
systemctl start sleepy_weepy.service

# Verify installation
if systemctl is-active --quiet sleepy_weepy.service; then
    echo -e "${GREEN}Installation successful!${NC}"
    echo "You can check the status with: sudo systemctl status sleepy_weepy.service"
    echo "Configuration file is at: /etc/sleepy_weepy/config.conf"
else
    echo -e "${RED}Installation failed. Please check the logs:${NC}"
    echo "sudo journalctl -u sleepy_weepy.service"
    exit 1
fi 