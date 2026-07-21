#!/bin/bash

PIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/cliphist-pinned"
mkdir -p "$PIN_DIR"

rofi_action=(-l 3)
rofi_main=(-l 12)

case "${1:-clip}" in
    clip)
        pinned_hashes=()
        pinned_displays=()
        for f in "$PIN_DIR"/*; do
            [ -f "$f" ] || continue
            hash=$(basename "$f")
            preview=$(head -c 80 "$f" | tr '\n' ' ' | sed 's/[[:cntrl:]]//g')
            pinned_hashes+=("$hash")
            pinned_displays+=("📌 ${preview:-(empty)}")
        done

        pinned_text=""
        for d in "${pinned_displays[@]}"; do
            pinned_text="${pinned_text}${d}"$'\n'
        done

        list=$(cliphist list)
        [ "${#pinned_hashes[@]}" -eq 0 ] && [ -z "$list" ] && exit 0

        combined=$(printf '%s\n' "${pinned_text%$'\n'}" "$list" | sed '/^$/d')
        idx=$(echo "$combined" | rofi -dmenu -p "clipboard" -i -format i "${rofi_main[@]}")
        [ -z "$idx" ] && exit 0

        pcount="${#pinned_hashes[@]}"
        if [ "$idx" -lt "$pcount" ]; then
            file="$PIN_DIR/${pinned_hashes[$idx]}"
            action=$(printf " Copy\n🗑 Delete" | rofi -dmenu -p "action" "${rofi_action[@]}")
            case "$action" in
                *Copy)   printf '%s' "$(cat "$file")" | xclip -selection clipboard && twmnc -t cliphist -c "copied pinned" -d 1500 ;;
                *Delete) rm -f "$file" && twmnc -t cliphist -c "pinned deleted" -d 1500 ;;
            esac
        else
            cline=$((idx - pcount + 1))
            line=$(echo "$list" | sed -n "${cline}p")
            id=$(echo "$line" | awk '{print $1}')
            [ -z "$id" ] && exit 0
            action=$(printf " Copy\n📌 Pin\n🗑 Delete" | rofi -dmenu -p "action" "${rofi_action[@]}")
            case "$action" in
                *Copy)
                    echo "$line" | cliphist decode | xclip -selection clipboard
                    twmnc -t cliphist -c "copied" -d 1500
                    ;;
                *Pin)
                    content=$(echo "$line" | cliphist decode)
                    [ -z "$content" ] && exit 0
                    name=$(printf '%s' "$content" | sha1sum | cut -c1-40)
                    printf '%s' "$content" > "$PIN_DIR/$name"
                    twmnc -t cliphist -c "pinned" -d 1500
                    ;;
                *Delete)
                    cliphist delete "$id" && twmnc -t cliphist -c "deleted $id" -d 1500
                    ;;
            esac
        fi
        ;;
    pass)
        entries=$(find "${PASSWORD_STORE_DIR:-$HOME/.password-store}" -name '*.gpg' -printf '%P\n' 2>/dev/null | sed 's/\.gpg$//' | sort)
        if [ -z "$entries" ]; then
            twmnc -t pass -c "password store empty" -d 2000
            exit 0
        fi
        choice=$(echo "$entries" | rofi -dmenu -p "pass" -i "${rofi_main[@]}")
        [ -n "$choice" ] && pass -c "$choice" 2>/dev/null && twmnc -t pass -c "copied $choice" -d 1500
        ;;
esac
