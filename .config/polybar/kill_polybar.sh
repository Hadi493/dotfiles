#!/bin/bash

# Check if polybar is running
if ! pgrep -x polybar > /dev/null; then
    echo "Polybar is not running"
    exit 1
fi

# Terminate polybar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

echo "Polybar stopped..."
