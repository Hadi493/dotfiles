#!/bin/bash

# Toggle polybar on/off
if pgrep -x polybar > /dev/null; then
    # Polybar is running, kill it
    ~/.config/polybar/kill_polybar.sh
else
    # Polybar is not running, start it
    ~/.config/polybar/start_polybar.sh
fi
