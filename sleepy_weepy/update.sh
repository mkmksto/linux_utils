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

# Check if service exists
if ! systemctl list-unit-files | grep -q sleepy_weepy.service; then
    echo -e "${RED}Sleepy Weepy is not installed.${NC}"
    echo "Please use install.sh to install first."
    exit 1
fi

echo -e "${YELLOW}Stopping service...${NC}"
systemctl stop sleepy_weepy.service

echo -e "${YELLOW}Backing up configuration...${NC}"
if [ -f "/etc/sleepy_weepy/config.conf" ]; then
    cp /etc/sleepy_weepy/config.conf /etc/sleepy_weepy/config.conf.backup
fi

echo -e "${YELLOW}Updating files...${NC}"
cp sleepy_weepy.sh /usr/local/bin/
chmod +x /usr/local/bin/sleepy_weepy.sh
cp sleepy_weepy_alarmey.wav /usr/local/share/sleepy_weepy/

echo -e "${YELLOW}Starting service...${NC}"
systemctl daemon-reload
systemctl start sleepy_weepy.service

# Verify update
if systemctl is-active --quiet sleepy_weepy.service; then
    echo -e "${GREEN}Update successful!${NC}"
    echo "Previous configuration has been preserved."
    echo "Backup saved at: /etc/sleepy_weepy/config.conf.backup"
    echo "You can check the status with: sudo systemctl status sleepy_weepy.service"
else
    echo -e "${RED}Update failed. Please check the logs:${NC}"
    echo "sudo journalctl -u sleepy_weepy.service"
    exit 1
fi 