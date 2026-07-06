#!/bin/bash

# Get the default sink
sink=$(pactl info | grep "Default Sink" | awk '{print $3}')

# Volume percentage
volume=$(pactl get-sink-volume "$sink" | grep -oP '\d+%' | head -n1)

# Mute status
mute=$(pactl get-sink-mute "$sink" | awk '{print $2}')

if [[ "$mute" == "yes" ]]; then
    echo "muted"
else
    echo "$volume"
fi
