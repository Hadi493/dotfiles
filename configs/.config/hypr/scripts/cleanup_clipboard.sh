#!/bin/bash

# This script removes clipboard history older than one month, respecting 'lifetime' flag.

# The clipboard history file
HISTORY_FILE="/home/cg/.config/hypr/clipboard/history"

# Ensure the history file exists and is a valid JSON array
if [ ! -f "$HISTORY_FILE" ] || ! jq -e . "$HISTORY_FILE" > /dev/null 2>&1; then
  echo "[]" > "$HISTORY_FILE"
  exit 0 # Nothing to clean if file is empty or invalid
fi

# Calculate the timestamp for one month ago
# Using GNU date for '-d' option
ONE_MONTH_AGO_SECONDS=$(date -d "1 month ago" +%s)

# Filter the history
jq --argjson one_month_ago_seconds "$ONE_MONTH_AGO_SECONDS" '
  map(
    select(
      .lifetime == true or
      (
        (.timestamp | strptime("%Y-%m-%d %H:%M:%S") | mktime) >= $one_month_ago_seconds
      )
    )
  )
' "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
