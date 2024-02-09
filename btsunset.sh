#!/bin/bash
/opt/homebrew/sbin/sleepwatcher --verbose --sleep $HOME/.btsunset/.sleep --wakeup $HOME/.btsunset/.wakeup > $HOME/.btsunset/sleepwatcher.log 2>&1
