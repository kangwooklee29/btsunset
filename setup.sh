#!/bin/bash

launchctl unload ~/Library/LaunchAgents/com.kangwooklee29.btsunset.plist

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

mkdir -p ~/.btsunset

cp "${SCRIPT_DIR}/btsunset.sh" ~/.btsunset/

cp "${SCRIPT_DIR}/com.kangwooklee29.btsunset.plist" ~/Library/LaunchAgents/

touch ~/.btsunset/turn_off_time

launchctl load ~/Library/LaunchAgents/com.kangwooklee29.btsunset.plist

echo "installed BTSunset successfully!"
