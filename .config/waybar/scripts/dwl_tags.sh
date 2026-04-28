#!/bin/bash
# Script to parse dwl output for Waybar tags
# Requires dwl to be run like: dwl > ~/.cache/dwl_status

STATUS_FILE="$HOME/.cache/dwl_status"

if [ ! -f "$STATUS_FILE" ]; then
    echo "{"text": "No Status", "tooltip": "Run dwl > $STATUS_FILE"}"
    exit 0
fi

# Example parsing logic for a typical dwl status line
# You might need to adjust this based on your dwl build's output format
# This is a placeholder that just shows the last line for now
last_line=$(tail -n 1 "$STATUS_FILE")
echo "{"text": "$last_line", "tooltip": "$last_line"}"
