#!/bin/bash

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

PRIMARY_MONITOR=$(xrandr --query | grep " primary" | cut -d" " -f1)
MONITOR=$PRIMARY_MONITOR polybar --reload toph &

echo "Polybar launched on $PRIMARY_MONITOR..."

