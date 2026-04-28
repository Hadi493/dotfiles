#!/bin/bash
player_status=$(playerctl status 2> /dev/null)
if [[ $? -eq 0 ]]; then
    echo "$(playerctl metadata artist) - $(playerctl metadata title)"
fi
