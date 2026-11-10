#!/usr/bin/env bash
# waybar notification indicator: wraps swaync's event stream so the count is
# hidden when empty and a bell icon is always shown.
set -u

swaync-client --subscribe-waybar | while IFS= read -r line; do
    text=$(printf '%s' "$line" | jq -r '.text // "0"')
    class=$(printf '%s' "$line" | jq -r '.class // "none"')
    tooltip=$(printf '%s' "$line" | jq -r '.tooltip // ""')
    case "$text" in ''|*[!0-9]*) text=0 ;; esac

    if [ "$class" = "dnd-notification" ]; then
        printf '{"text":"󰂛 %s","tooltip":"%s","class":"dnd-notification"}\n' "$text" "$tooltip"
    elif [ "$text" -gt 0 ]; then
        printf '{"text":"󰂚 %s","tooltip":"%s","class":"notification"}\n' "$text" "$tooltip"
    else
        printf '{"text":"󰂜","tooltip":"%s","class":"none"}\n' "$tooltip"
    fi
done
