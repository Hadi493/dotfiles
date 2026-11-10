#!/usr/bin/env bash
# Current MPRIS track for the lock screen.
meta=$(playerctl metadata --format '{{artist}}|{{title}}' 2>/dev/null | head -1)
artist=${meta%%|*}
title=${meta#*|}
if [ -n "$artist" ] && [ -n "$title" ]; then
    printf '%s — %s\n' "$artist" "$title"
elif [ -n "$title" ]; then
    printf '%s\n' "$title"
elif [ -n "$artist" ]; then
    printf '%s\n' "$artist"
fi
