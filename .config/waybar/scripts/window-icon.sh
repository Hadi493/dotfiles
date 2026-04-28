#!/bin/bash

# Get the active window class
active_window=$(hyprctl activewindow -j | jq -r '.class')

if [ "$active_window" = "null" ] || [ -z "$active_window" ]; then
    echo ""
    exit 0
fi

# Convert class to lowercase for matching
class=$(echo "$active_window" | tr '[:upper:]' '[:lower:]')

# Map class names to icon names
case $class in
    "firefox")
        icon="firefox"
        ;;
    "google-chrome"|"chromium"|"chromium-browser")
        icon="chromium"
        ;;
    "code"|"visual-studio-code")
        icon="code"
        ;;
    "discord")
        icon="discord"
        ;;
    "spotify")
        icon="spotify"
        ;;
    "steam")
        icon="steam"
        ;;
    "thunar"|"nautilus"|"dolphin")
        icon="folder"
        ;;
    "gimp")
        icon="gimp"
        ;;
    "kitty"|"alacritty"|"terminator")
        icon="terminal"
        ;;
    "obs"|"obs-studio")
        icon="obs-studio"
        ;;
    "telegram-desktop")
        icon="telegram"
        ;;
    "vlc")
        icon="vlc"
        ;;
    "blender")
        icon="blender"
        ;;
    "libreoffice-writer"|"libreoffice-calc"|"libreoffice")
        icon="libreoffice"
        ;;
    "inkscape")
        icon="inkscape"
        ;;
    "pavucontrol")
        icon="audio-card"
        ;;
    "zed")
        icon="text-editor"
        ;;
    *)
        icon="application-x-executable"
        ;;
esac

# Try to find the icon in the system
icon_path=$(find /usr/share/icons /usr/share/pixmaps ~/.local/share/icons -name "${icon}.*" -type f 2>/dev/null | head -1)

if [ -n "$icon_path" ]; then
    echo "<img src='$icon_path' width='18' height='18'/>"
else
    # Fallback to text if no icon found
    echo "$active_window"
fi
