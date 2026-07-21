#!/bin/bash
DIR="$HOME/Pictures/screenshots"
mkdir -p "$DIR"
MODE="${1:-region}"

case "$MODE" in
    region)
        FILE="$DIR/shot_$(date +%Y%m%d_%H%M%S).png"
        import "$FILE"
        xclip -selection clipboard -t image/png -i "$FILE" 2>/dev/null
        twmnc -t "Screenshot" -c "Region saved + copied" -d 2000 2>/dev/null
        ;;
    full)
        FILE="$DIR/shot_$(date +%Y%m%d_%H%M%S).png"
        import -window root "$FILE"
        xclip -selection clipboard -t image/png -i "$FILE" 2>/dev/null
        twmnc -t "Screenshot" -c "Full screen saved + copied" -d 2000 2>/dev/null
        ;;
esac
