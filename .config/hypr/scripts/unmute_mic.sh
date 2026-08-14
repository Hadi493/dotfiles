#!/bin/bash
until pactl info >/dev/null 2>&1; do sleep 0.5; done
pactl list short sources | awk '/^[0-9]+\talsa_input/{print $2}' | while read -r s; do
    pactl set-source-mute "$s" 0
done
pactl set-default-source echo-cancel-source 2>/dev/null
pactl set-default-sink echo-cancel-sink 2>/dev/null
