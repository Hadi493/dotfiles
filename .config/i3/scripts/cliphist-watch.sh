#!/bin/bash

prev=""
while true; do
  cur=$(xclip -selection clipboard -o 2>/dev/null)
  if [ -n "$cur" ] && [ "$cur" != "$prev" ]; then
    printf '%s' "$cur" | cliphist store 2>/dev/null
    prev="$cur"
  fi
  sleep 1
done
