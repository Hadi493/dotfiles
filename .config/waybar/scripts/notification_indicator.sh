#!/bin/bash

# Notification indicator script for waybar
# Shows different icon based on notification status (Noctalia only)

if command -v noctalia &> /dev/null; then
    # Use Noctalia DND state
    if [ "$(noctalia msg notification-dnd-status 2>/dev/null)" = "on" ]; then
        echo '{"text":"󰂛","tooltip":"Do Not Disturb enabled","class":"notification"}'
    else
        echo '{"text":"󰂜","tooltip":"Noctalia notifications","class":"empty"}'
    fi
else
    # Fallback
    echo '{"text":"󰂜","tooltip":"Click to view system messages","class":"empty"}'
fi