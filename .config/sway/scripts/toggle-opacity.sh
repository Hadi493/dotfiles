#!/usr/bin/env bash
set -euo pipefail

# === CONFIG ===
STATE_DIR="/tmp/sway_opacity_states"
mkdir -p "$STATE_DIR"

# Get focused window ID (works for both native and XWayland)
focused_id=$(swaymsg -t get_tree | jq '.. | objects | select(.focused==true).id')
if [ -z "$focused_id" ]; then
    notify-send "Sway Opacity" "No active window found"
    exit 1
fi

STATE_FILE="$STATE_DIR/${focused_id}.state"

# Read old opacity or set default
current_alpha=$(cat "$STATE_FILE" 2>/dev/null || echo "1.0")

# Toggle
if awk "BEGIN {exit !($current_alpha >= 0.99)}"; then
    new_alpha="0.85"
    msg="Set to transparent (85%)"
else
    new_alpha="1.0"
    msg="Set to fully opaque (100%)"
fi

# Apply via swaymsg (only works for global or container opacity)
swaymsg "[con_id=$focused_id]" opacity "$new_alpha" >/dev/null 2>&1 || true

echo "$new_alpha" > "$STATE_FILE"
notify-send "Sway Opacity" "$msg"
