#!/bin/bash

# Optimized clipboard synchronization with auto-cleanup and proper ordering
set -e

# Clipboard history file
HISTORY_FILE="/home/cg/.config/hypr/clipboard/history"

# Ensure the history file exists and is a valid JSON array
if [ ! -f "$HISTORY_FILE" ] || ! jq -e . "$HISTORY_FILE" > /dev/null 2>&1; then
  echo "[]" > "$HISTORY_FILE"
fi

# Function to add a new entry to the history
add_to_history() {
  local content="$1"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  # Read current history
  local history_json=$(cat "$HISTORY_FILE")

  # Check if content already exists in history (to avoid duplicates)
  # This is a basic check, a more robust one might involve hashing or deeper comparison
  if echo "$history_json" | jq -e --arg content "$content" '.[] | select(.content == $content)' > /dev/null; then
    return # Content already exists, do not add
  fi

  # Add new entry
  local new_entry=$(jq -n \
    --arg content "$content" \
    --arg timestamp "$timestamp" \
    '{content: $content, timestamp: $timestamp, category: "default", lifetime: false}')

  local updated_history=$(echo "$history_json" | jq ". + [$new_entry]")

  echo "$updated_history" > "$HISTORY_FILE"
}

# Lightweight sync with reduced frequency
sync_clipboards() {
    last_primary=""
    last_clipboard=""
    
    while true; do
        # Check primary selection
        current_primary=$(wl-paste -p -n -t text 2>/dev/null || echo "")
        if [ "$current_primary" != "$last_primary" ] && [ -n "$current_primary" ]; then
            echo "$(date): Primary clipboard changed: $current_primary" >> /tmp/clipboard_sync.log
            wl-copy -n "$current_primary" 2>/dev/null || true
            add_to_history "$current_primary"
            last_primary="$current_primary"
        fi
        
        # Check clipboard
        current_clipboard=$(wl-paste -n -t text 2>/dev/null || echo "")
        if [ "$current_clipboard" != "$last_clipboard" ] && [ -n "$current_clipboard" ]; then
            echo "$(date): Clipboard changed: $current_clipboard" >> /tmp/clipboard_sync.log
            wl-copy -p -n "$current_clipboard" 2>/dev/null || true
            add_to_history "$current_clipboard"
            last_clipboard="$current_clipboard"
        fi
        
        sleep 1
    done
}

# Start background processes
sync_clipboards &

# Keep script running
wait