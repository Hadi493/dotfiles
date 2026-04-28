#!/bin/bash

# Directory containing your wallpapers
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Check if the directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    rofi -e "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

# Rofi theme file
ROFI_THEME="$HOME/.config/rofi/wallpaper.rasi"

# Find all wallpapers and pipe them to rofi
# Output format: full_path\0icon\x1ffull_path\n
find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) -print0 | \
    while IFS= read -r -d $'\0' wallpaper; do
        echo -e "$wallpaper\0icon\x1f$wallpaper"
    done | \
    rofi -dmenu -p "Select Wallpaper" -theme "$ROFI_THEME" -show-icons -case-smart | \
    while read -r selected_wallpaper_path; do
        if [ -n "$selected_wallpaper_path" ]; then
            filename=$(basename "$selected_wallpaper_path")
            foldername=$(basename "$(dirname "$selected_wallpaper_path")")
            # Use feh for i3/X11
            feh --bg-fill "$selected_wallpaper_path"
            # Update .fehbg for next session
            echo "#!/bin/sh" > "$HOME/.fehbg"
            echo "feh --no-fehbg --bg-fill '$selected_wallpaper_path'" >> "$HOME/.fehbg"
            chmod +x "$HOME/.fehbg"
            
            echo "$selected_wallpaper_path" > "$HOME/.cache/last_wallpaper.path"
            wal -i "$selected_wallpaper_path"
			sleep 1
			twmnc --title "swaync" --content "Wallpaper changed: [$foldername] $filename"
        fi
    done
