#!/bin/bash

HYPR_STATE=$(hyprctl getoption animations:enabled | awk 'NR==1{print $2}')

if [ "$HYPR_STATE" = "1" ]; then
    hyprctl keyword animations:enabled false
    notify-send -u low -t 1200 "Animations" "Disabled — max performance"
else
    hyprctl keyword animations:enabled true
    notify-send -u low -t 1200 "Animations" "Enabled"
fi
