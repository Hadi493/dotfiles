#!/usr/bin/env bash
set -u

LOG=/tmp/noctalia-cliphist-migration.log
: > "$LOG"

get_type() {
    local id="$1"
    cliphist list | awk -F '\t' -v id="$id" '$1 == id { print $2 }'
}

main() {
    local ids
    ids=$(cliphist list | cut -f1 | tac)

    local count=0
    local id
    while IFS= read -r id; do
        count=$((count + 1))

        local preview
        preview=$(cliphist list | awk -F '\t' -v id="$id" '$1 == id { print $2 }')

        if [[ "$preview" == *"binary data"* ]]; then
            echo "[$count/750] SKIP image/file entry id=$id" >> "$LOG"
            continue
        fi

        local text
        text=$(cliphist decode "$id" 2>/dev/null)
        if [[ -z "$text" ]]; then
            echo "[$count/750] SKIP empty id=$id" >> "$LOG"
            continue
        fi

        if printf '%s' "$text" | wl-copy; then
            echo "[$count/750] OK id=$id" >> "$LOG"
        else
            echo "[$count/750] FAIL id=$id" >> "$LOG"
        fi

        # let noctalia capture the selection before the next one
        sleep 0.2
    done <<< "$ids"

    echo "DONE migrated $count entries" >> "$LOG"
    notify-send "Cliphist migration" "Replayed $count entries into Noctalia clipboard history"
}

main "$@"
