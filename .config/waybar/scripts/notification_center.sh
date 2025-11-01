#!/bin/bash

# Simple notification center script
# This is a lighter alternative to the full control center

if command -v swaync-client &> /dev/null; then
    swaync-client -t -sw
elif command -v dunstctl &> /dev/null; then
    # Show dunst notification history
    dunstctl history-pop
else
    # Fallback: show recent system messages
    journalctl --user -n 10 --no-pager | rofi -dmenu -p "System Messages" -theme ~/.config/rofi/config.rasi
fi