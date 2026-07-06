#!/bin/bash

case "${1:-clip}" in
    clip)
        rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}'
        ;;
    pass)
        entries=$(find "${PASSWORD_STORE_DIR:-$HOME/.password-store}" -name '*.gpg' -printf '%P\n' 2>/dev/null | sed 's/\.gpg$//' | sort)
        if [ -z "$entries" ]; then
            twmnc -t "pass" -c "password store empty" -d 2000
            exit 0
        fi
        choice=$(echo "$entries" | rofi -dmenu -p "pass" -i)
        [ -n "$choice" ] && pass -c "$choice" 2>/dev/null && twmnc -t "pass" -c "copied $choice" -d 1500
        ;;
esac
