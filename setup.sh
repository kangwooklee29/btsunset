#!/bin/bash

plist_file_name="com.kangwooklee29.btsunset.plist"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

mkdir -p ~/.btsunset
touch ~/.btsunset/turn_off_time
cp "${SCRIPT_DIR}/btsunset.sh" ~/.btsunset/
cp "${SCRIPT_DIR}/${plist_file_name}" ~/Library/LaunchAgents/

btsunset_file_path="${HOME}/.btsunset/btsunset.sh"
sed -i '' "s|<string></string>|<string>${btsunset_file_path}</string>|g" "${HOME}/Library/LaunchAgents/${plist_file_name}"

launchctl unload ~/Library/LaunchAgents/com.kangwooklee29.btsunset.plist
launchctl load ~/Library/LaunchAgents/com.kangwooklee29.btsunset.plist

echo "installed BTSunset successfully!"
