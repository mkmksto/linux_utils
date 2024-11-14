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

echo -e "${YELLOW}Stopping and disabling service...${NC}"
systemctl stop sleepy_weepy.service
systemctl disable sleepy_weepy.service

echo -e "${YELLOW}Removing files...${NC}"
rm -f /etc/systemd/system/sleepy_weepy.service
rm -f /usr/local/bin/sleepy_weepy.sh
rm -rf /etc/sleepy_weepy
rm -rf /usr/local/share/sleepy_weepy

echo -e "${YELLOW}Reloading systemd...${NC}"
systemctl daemon-reload

# Verify uninstallation
if [ ! -f "/usr/local/bin/sleepy_weepy.sh" ] && \
   [ ! -f "/etc/systemd/system/sleepy_weepy.service" ] && \
   [ ! -d "/etc/sleepy_weepy" ] && \
   [ ! -d "/usr/local/share/sleepy_weepy" ]; then
    echo -e "${GREEN}Uninstallation successful!${NC}"
else
    echo -e "${RED}Some files could not be removed. Please check manually.${NC}"
    exit 1
fi 