#!/bin/bash

HYPR_STATE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')

if [ "$HYPR_STATE" = "1" ]; then
    hyprctl eval 'hl.config({ animations = { enabled = false } })'
    notify-send -u low -t 1200 "Animations" "Disabled — max performance"
else
    hyprctl eval 'hl.config({ animations = { enabled = true } })'
    notify-send -u low -t 1200 "Animations" "Enabled"
fi
