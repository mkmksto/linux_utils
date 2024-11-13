#!/bin/bash

# Configuration file path
CONFIG_FILE="/etc/sleepy_weepy/config.conf"
DEFAULT_SOUND="/usr/local/share/sleepy_weepy/sleepy_weepy_alarmey.wav"

# Function to play sound
play_sound() {
    local sound_file="$1"
    if [ -f "$sound_file" ]; then
        # Try to play with paplay (PulseAudio) first
        if command -v paplay >/dev/null 2>&1; then
            paplay "$sound_file" &
        # Fallback to aplay (ALSA)
        elif command -v aplay >/dev/null 2>&1; then
            aplay "$sound_file" &
        fi
    fi
}

# Function to show notification
show_notification() {
    local message="$1"
    # Try to send notification to all active users
    for user in $(who | cut -d' ' -f1 | sort | uniq); do
        uid=$(id -u "$user")
        if [ ! -z "$uid" ]; then
            sudo -u "$user" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send "Sleepy Weepy" "$message"
        fi
    done
}

# Function to check if it's time to sleep
check_sleep_time() {
    local target_hour="$1"
    local message="$2"
    local sound_file="$3"
    
    current_hour=$(date +%H)
    
    if [ "$current_hour" -eq "$target_hour" ]; then
        if [ ! -z "$message" ]; then
            show_notification "$message"
        fi
        
        # Use default sound if no custom sound is specified
        if [ -z "$sound_file" ]; then
            sound_file="$DEFAULT_SOUND"
        fi
        
        play_sound "$sound_file"
        
        # Wait for notifications and sound to complete
        sleep 5
        
        # Suspend the system
        systemctl suspend
        
        # Wait for 1 hour to avoid multiple suspends
        sleep 3600
    fi
}

# Main loop
main() {
    # Create default config if it doesn't exist
    if [ ! -f "$CONFIG_FILE" ]; then
        mkdir -p "$(dirname "$CONFIG_FILE")"
        cat > "$CONFIG_FILE" << EOL
# Sleep hour (0-23)
SLEEP_HOUR=21

# Notification message (optional)
MESSAGE="Sleepy Weepy is going to sleep now"

# Sound file path (optional, leave empty to use default sound)
SOUND_FILE=""
EOL
    fi
    
    # Main loop
    while true; do
        if [ -f "$CONFIG_FILE" ]; then
            source "$CONFIG_FILE"
            check_sleep_time "$SLEEP_HOUR" "$MESSAGE" "$SOUND_FILE"
        fi
        sleep 60
    done
}

main 