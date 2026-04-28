#!/usr/bin/env bash

# Check for pacman updates
if ! updates_arch=$(checkupdates 2> /dev/null | wc -l); then
    updates_arch=0
fi

# Check for AUR updates (yay)
if ! updates_aur=$(yay -Qua 2> /dev/null | wc -l); then
    updates_aur=0
fi

updates=$((updates_arch + updates_aur))

if [ "$updates" -gt 0 ]; then
    echo "{\"text\": \"$updates\", \"tooltip\": \"Arch: $updates_arch\nAUR: $updates_aur\"}"
else
    echo "{\"text\": \"0\", \"tooltip\": \"Up to date\"}"
fi
