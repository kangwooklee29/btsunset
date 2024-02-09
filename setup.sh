#!/bin/bash

plist_file_name="com.kangwooklee29.btsunset.plist"

check_program() {
    program_name=$1
    if ! command -v $program_name &>/dev/null; then
        echo "$program_name is not installed. Please install it using brew."
        echo "Run: brew install $program_name"
        exit 1
    fi
}

install_plist_file() {
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

    cp "${SCRIPT_DIR}/${plist_file_name}" ~/Library/LaunchAgents/

    sed -i '' "s|YourUsername|${HOME}|g" "${HOME}/Library/LaunchAgents/${plist_file_name}"

    launchctl unload ~/Library/LaunchAgents/com.kangwooklee29.btsunset.plist
    launchctl load ~/Library/LaunchAgents/com.kangwooklee29.btsunset.plist
}

check_program blueutil
check_program sleepwatcher

mkdir -p ~/.btsunset

echo "/opt/homebrew/bin/blueutil -p 0" > ~/.btsunset/.sleep
echo "/opt/homebrew/bin/blueutil -p 1" > ~/.btsunset/.wakeup

chmod +x ~/.btsunset/.sleep
chmod +x ~/.btsunset/.wakeup

cp btsunset.sh ~/.btsunset

install_plist_file

echo "installed BTSunset successfully!"
