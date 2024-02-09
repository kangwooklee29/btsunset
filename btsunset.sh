#!/bin/bash

# Global variables
log_file_path="/tmp/com.kangwooklee29.btsunset.log"
ap_list_path="$HOME/.btsunset/current_wifi_ap_list"
turn_off_time_path="$HOME/.btsunset/turn_off_time"

# Logging function
log_message() {
    echo "$1" >> "$log_file_path"
}

# Check and trim log file
check_trim_log() {
    if [ $(wc -l < "$log_file_path") -gt 10 ]; then
        sed -i '' '1,2d' "$log_file_path"
    fi
}

# Checks Bluetooth turn-off time
check_turn_off_time() {
    if [ $(( $(date +%s) - $(stat -f "%m" "$turn_off_time_path" 2>/dev/null || echo 0) )) -le 10800 ]; then
        log_message "Script ended, reason: 3 hours"
        exit 0
    fi
}

# Check if blueutil is installed
check_blueutil() {
    if ! command -v blueutil &>/dev/null; then
        echo "blueutil is not installed. Please install it using brew."
        echo "Run: brew install blueutil"
        log_message "Script ended, reason: no blueutil"
        exit 1
    fi
}

# Find and validate the Airport utility
find_airport() {
    airport_path=$(find /System/Library/PrivateFrameworks/ -name airport 2>/dev/null)
    for path in $airport_path; do
        if "$path" -s &>/dev/null; then
            echo "$path"
            return
        fi
    done
    return 1
}

# Check if current AP list is different from the previous
check_ap_list_difference() {
    airport=$1
    current_ap_list=$($airport -s | tail -n +2 | awk '{print $1}')
    if [ ! -f "$ap_list_path" ]; then
        echo "$current_ap_list" > "$ap_list_path"
        log_message "Script ended, reason: Initialized AP list"
        exit 0
    fi

    previous_ap_list=$(cat "$ap_list_path")

    for current_ap in $current_ap_list; do
        if grep -q -x "$current_ap" <<< "$previous_ap_list"; then
            return 1 # Not Unique
        fi
    done

    return 0 # Unique
}

# Main script logic
main() {
    check_trim_log
    log_message "Script started at: $(date)"
    check_turn_off_time
    check_blueutil
    airport=$(find_airport)
    if [ $? -ne 0 ]; then
        echo "cannot find airport utility."
        log_message "Script ended, reason: no airport"
        exit 1
    fi

    if check_ap_list_difference "$airport"; then
        blueutil -p 0 # turn off bluetooth
        touch "$turn_off_time_path"
        echo $($airport -s | tail -n +2 | awk '{print $1}') > "$ap_list_path"
        log_message "Bluetooth turned off due to new network."
    else
        log_message "Same network detected. Bluetooth remains on."
    fi

    log_message "Script ended, reason: script succeeded"
}

# Execute main function
main
