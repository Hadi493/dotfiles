#!/bin/bash

# Toggle Waybar on/off

if pgrep -x "waybar" > /dev/null; then
    pkill waybar
else
    waybar &
fi
