#!/bin/bash

# Notification indicator script for waybar
# Shows different icon based on notification status

if command -v swaync-client &> /dev/null; then
    # Use swaync if available
    swaync-client -swb
elif command -v dunstctl &> /dev/null; then
    # Use dunst if available
    count=$(dunstctl count displayed 2>/dev/null || echo "0")
    if [ "$count" -gt 0 ]; then
        echo '{"text":"󰅸","tooltip":"'$count' notifications","class":"notification"}'
    else
        echo '{"text":"󰂜","tooltip":"No notifications","class":"empty"}'
    fi
else
    # Fallback
    echo '{"text":"󰂜","tooltip":"Click to view system messages","class":"empty"}'
fi