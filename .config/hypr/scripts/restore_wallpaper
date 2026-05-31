#!/bin/bash

# CACHE FILE
LAST_WALLPAPER_CACHE="$HOME/.cache/last_wallpaper.path"

# Kill any existing swaybg instances
pkill -x swaybg

# Restore last wallpaper if cache file exists
if [ -f "$LAST_WALLPAPER_CACHE" ]; then
    WALLPAPER_PATH=$(cat "$LAST_WALLPAPER_CACHE")
    if [ -n "$WALLPAPER_PATH" ]; then
        swaybg -i "$WALLPAPER_PATH" -m fill &
        
        # Set colors
        wal -i "$WALLPAPER_PATH"
        killall -SIGUSR2 waybar
        killall swaync
        dbus-launch swaync &
        sleep 1
    fi
fi

