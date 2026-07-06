#!/bin/bash
STEP=5

get_current() {
    bright=$(brightnessctl get 2>/dev/null)
    max=$(brightnessctl max 2>/dev/null)
    if [ -n "$bright" ] && [ -n "$max" ] && [ "$max" -gt 0 ]; then
        echo $(( bright * 100 / max ))
    else
        echo 50
    fi
}

case "$1" in
    up)
        new=$(( $(get_current) + STEP ))
        [ "$new" -gt 100 ] && new=100
        brightnessctl set "${new}%" 2>/dev/null || xbacklight -inc "$STEP" 2>/dev/null
        ;;
    down)
        new=$(( $(get_current) - STEP ))
        [ "$new" -lt 1 ] && new=1
        brightnessctl set "${new}%" 2>/dev/null || xbacklight -dec "$STEP" 2>/dev/null
        ;;
    max)
        brightnessctl set 100% 2>/dev/null || xbacklight -set 100 2>/dev/null
        ;;
esac

twmnc -t "Brightness" -c "${new:-$(get_current)}%" -d 700 2>/dev/null || true
