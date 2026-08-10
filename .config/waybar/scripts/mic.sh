#!/bin/bash
# mic.sh - JSON output for dock microphone module
vol=$(pactl get-source-volume @DEFAULT_SOURCE@ 2>/dev/null | awk -F'/' '/Volume/{gsub(/[% ]/,"",$2); print $2}')
if pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | grep -q "yes"; then
    echo '{"text":"󰍭","tooltip":"Mic muted","class":"muted"}'
    exit 0
fi
echo "{\"text\":\"󰍬 $vol%\",\"tooltip\":\"Mic $vol%\"}"
