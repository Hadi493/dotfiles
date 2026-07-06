#!/bin/bash
STATE_FILE="/tmp/i3_opacity_toggle"

if [ ! -f "$STATE_FILE" ]; then
    echo "1" > "$STATE_FILE"
fi

STATE=$(cat "$STATE_FILE")

if [ "$STATE" = "1" ]; then
    picom-trans -c 0.88 2>/dev/null || true
    echo "0" > "$STATE_FILE"
    twmnc -t "Opacity" -c "0.88" -d 700 2>/dev/null || true
else
    picom-trans -c 1.0 2>/dev/null || true
    echo "1" > "$STATE_FILE"
    twmnc -t "Opacity" -c "1.0" -d 700 2>/dev/null || true
fi
