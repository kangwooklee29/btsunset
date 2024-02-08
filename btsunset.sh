#!/bin/bash

if [ $(( $(date +%s) - $(stat -f "%m" ~/.btsunset/turn_off_time) )) -le 10800 ]; then
    # bluetooth was turned off in last 3 hours.
    exit 0
fi

if ! command -v blueutil &> /dev/null; then
    echo "blueutil is not installed. Please install it using brew."
    echo "Run: brew install blueutil"
fi

airport_path=$(find /System/Library/PrivateFrameworks/ -name airport 2>/dev/null)

for path in $airport_path; do
    if $path -s &>/dev/null; then
        airport=$path
        break
    fi
done

if [ -z "$airport" ]; then
    echo "cannot find airport utility."
    exit 1
fi

current_ap_list=$($airport -s | tail -n +2 | awk '{print $1}')

ap_list_path="$HOME/.btsunset/current_wifi_ap_list"

if [ -z "$ap_list_path" ]; then
    echo $($airport -s | tail -n +2 | awk '{print $1}') >> $ap_list_path
    exit 0
fi

previous_ap_list=$(cat "$ap_list_path")

unique_flag=0
for current_ap in $current_ap_list; do
    if grep -q "$current_ap" <<< "$previous_ap_list"; then
        # previous_ap_list has current_ap.
        unique_flag=1
        break
    fi
done

# turn off bluetooth if the current ap list is totally different, as it means you left from the office.
if [ $unique_flag -eq 0 ]; then 
    blueutil -p 0
    touch ~/.btsunset/turn_off_time
fi

# update current_wifi_ap_list file to the latest.
echo $($airport -s | tail -n +2 | awk '{print $1}') >> $ap_list_path

# delete first line of current_wifi_ap_list file if it has more than ten rows.
if [ $(wc -l < "$ap_list_path") -gt 10 ]; then
    sed -i '1d' "$ap_list_path"
fi
