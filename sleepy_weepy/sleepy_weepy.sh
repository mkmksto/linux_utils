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
            sudo -u "$user" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" notify-send "Sleepy Weepy" "$message"
        fi
    done
}

# Function to check if it's time to sleep
check_sleep_time() {
    local target_hour="$1"
    local message="$2"
    local sound_file="$3"
    
    current_hour=$(date +%H)
    current_min=$(date +%M)
    
    # Check for 10 minutes before sleep time
    local check_hour=$target_hour
    # local check_minute=50
    
    # Adjust for previous hour if target is midnight
    if [ "$target_hour" -eq 0 ]; then
        check_hour=23
    else
        check_hour=$((target_hour - 1))
    fi
    
    # Check if it's between 50-53 minutes (i.e. 7-10 minutes) of the hour before sleep time
    if [ "$current_hour" -eq "$check_hour" ] && [ "$current_min" -ge 50 ] && [ "$current_min" -le 55 ]; then
        local mins_until=$(( (60 - current_min) + (target_hour - current_hour - 1) * 60 ))
        show_notification "Going to sleep in $mins_until minutes..."
        # Use default sound if no custom sound is specified
        if [ -z "$sound_file" ]; then
            sound_file="$DEFAULT_SOUND"
        fi
        
        play_sound "$sound_file"

    fi
    
    if [ "$current_hour" -eq "$target_hour" ] && [ "$current_min" -eq "0" ]; then
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
        # systemctl suspend
        systemctl hibernate
        
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
