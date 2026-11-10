#!/usr/bin/env bash
# Microphone indicator for waybar: icon + volume, muted state.
set -u

vol=$(pactl get-source-volume @DEFAULT_SOURCE@ 2>/dev/null | awk -F'/' '/Volume/{gsub(/[% ]/,"",$2); print $2; exit}')
if pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null | grep -q "yes"; then
    printf '{"text":" muted","tooltip":"Microphone muted","class":"muted"}\n'
    exit 0
fi
[ -z "$vol" ] && vol=0
printf '{"text":" %s%%","tooltip":"Microphone %s%%","class":"mic"}\n' "$vol" "$vol"
