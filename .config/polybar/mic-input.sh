#!/bin/bash

# Get the default source
source=$(pactl info | grep "Default Source" | awk '{print $3}')

# Volume percentage
volume=$(pactl get-source-volume "$source" | grep -oP '\d+%' | head -n1)

# Mute status
mute=$(pactl get-source-mute "$source" | awk '{print $2}')

if [[ "$mute" == "yes" ]]; then
    echo "🔇 muted"
else
    echo "🎙️ $volume"
fi
