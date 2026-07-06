#!/bin/bash

pactl set-source-mute @DEFAULT_SOURCE@ toggle

if [[ $(pactl get-source-mute @DEFAULT_SOURCE@) == *"yes"* ]]; then
    twmnc -t "Mic" -c "Muted" -d 700
else
    twmnc -t "Mic" -c "Unmuted" -d 700
fi
