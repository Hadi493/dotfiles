#!/bin/bash

# Rofi-based clipboard history manager
# Requires: rofi, jq, wl-copy, wl-paste

HISTORY_FILE="/home/cg/.config/hypr/clipboard/history"

# Ensure the history file exists and is a valid JSON array
if [ ! -f "$HISTORY_FILE" ] || ! jq -e . "$HISTORY_FILE" > /dev/null 2>&1; then
  echo "[]" > "$HISTORY_FILE"
fi

# Function to display history and get user selection
get_selection() {
  jq -r '.[] | "\(.category) | \(.timestamp) | \(.content)"' "$HISTORY_FILE" | \
    rofi -dmenu -i -p "Clipboard History" -format "i"
}

# Function to get action for selected item
get_action() {
  echo -e "Copy to Clipboard\nToggle Lifetime\nSet Category\nDelete" | rofi -dmenu -i -p "Choose Action"
}

# Function to get new category
get_category() {
  echo -e "default\nfavorite\nwork\npersonal\npasswords" | rofi -dmenu -i -p "Set Category"
}

# Main logic
selected_index=$(get_selection)

if [ -z "$selected_index" ]; then
  exit 0 # User cancelled selection
fi

# Get the selected item's JSON object
# Corrected: Use --argjson to pass the index safely
selected_item=$(jq --argjson idx "$selected_index" '.[$idx]' "$HISTORY_FILE")

# Get action from user
action=$(get_action)

case "$action" in
  "Copy to Clipboard")
    content=$(echo "$selected_item" | jq -r '.content')
    echo "$content" | wl-copy
    ;;
  "Toggle Lifetime")
    updated_item=$(echo "$selected_item" | jq '.lifetime = (not .lifetime)')
    # Corrected: Use --argjson to pass the index safely
    jq --argjson idx "$selected_index" --argjson item "$updated_item" '.[$idx] = $item' "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
    ;;
  "Set Category")
    new_category=$(get_category)
    if [ -n "$new_category" ]; then
      updated_item=$(echo "$selected_item" | jq --arg cat "$new_category" '.category = $cat')
      # Corrected: Use --argjson to pass the index safely
      jq --argjson idx "$selected_index" --argjson item "$updated_item" '.[$idx] = $item' "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
    fi
    ;;
  "Delete")
    # Corrected: Use --argjson to pass the index safely
    jq --argjson idx "$selected_index" 'del(.[$idx])' "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
    ;;
  *)
    exit 0 # User cancelled action
    ;;
esac
