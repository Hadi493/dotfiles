#!/bin/bash

# WALLPAPER_DIR="$HOME/Pictures/wallpapers/fake-beauti-collections"

# WALLPAPER_DIR="$HOME/Pictures/wallpapers/collectionH"

# WALLPAPER_DIR="$HOME/Pictures/wallpapers/fighters"
 
WALLPAPER_DIR="$HOME/Pictures/wallpapers/nature-collections/"

# WALLPAPER_DIR="$HOME/Pictures/wallpapers/cg-wallpapers/"

# Start daemon if not running
if ! pgrep -x swww-daemon >/dev/null; then
    swww-daemon --format xrgb &
    sleep 0.5
fi

# Pick a random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n1)

# Set wallpaper with transition
swww img "$WALLPAPER" \
  --transition-type any \
  --transition-fps 70 \
  --transition-duration 0.66

wal -i "$WALLPAPER"
killall -SIGUSR2 waybar

# TOOLS:
# - sudo pacman -S swww
