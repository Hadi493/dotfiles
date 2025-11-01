#!/bin/bash

# Windows-like keyboard layout switcher for Waybar
# Shows current keyboard layout in a compact Windows-style format

# Get current keyboard layout from Hyprland
get_hyprland_layout() {
    local layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.name=="at-translated-set-2-keyboard") | .active_keymap' 2>/dev/null)
    if [[ -z "$layout" ]] || [[ "$layout" == "null" ]]; then
        # Fallback to setxkbmap
        layout=$(setxkbmap -query 2>/dev/null | grep layout | awk '{print $2}' | cut -d',' -f1)
    fi
    echo "$layout"
}

# Get current layout index from Hyprland
get_layout_index() {
    hyprctl devices -j | jq -r '.keyboards[] | select(.name=="at-translated-set-2-keyboard") | .layout' 2>/dev/null || echo "0"
}

# Get current input method in Windows-like format
get_current_layout() {
    local current=$(get_hyprland_layout)
    local index=$(get_layout_index)
    
    case "$current" in
        "English (US)"*|"us"*|"US"*)
            echo "ENG"
            ;;
        "Bangla (Probhat)"*|"Bengali (Probhat)"*|"*probhat*"*|"bd"*|"BD"*)
            echo "BEN"
            ;;
        "Arabic"*|"ar"*|"AR"*|"ara"*|"ARA"*)
            echo "ARA"
            ;;
        *)
            # Try to determine from setxkbmap as fallback
            local layout=$(setxkbmap -query 2>/dev/null | grep layout | awk '{print $2}' | cut -d',' -f1)
            case "$layout" in
                "us") echo "ENG" ;;
                "bd") echo "BEN" ;;
                "in") echo "BEN" ;;
                "ar") echo "ARA" ;;
                *) echo "${layout^^}" ;; # Convert to uppercase
            esac
            ;;
    esac
}

# Get full language name for notifications
get_full_name() {
    local current=$(get_hyprland_layout)
    case "$current" in
        "English (US)"*|"us"*|"US"*)
            echo "English (US)"
            ;;
        "Bangla (Probhat)"*|"Bengali (Probhat)"*|"*probhat*"*|"bd"*|"BD"*)
            echo "Bengali (Probhat)"
            ;;
        "Arabic"*|"ar"*|"AR"*|"ara"*|"ARA"*)
            echo "Arabic"
            ;;
        *)
            echo "$current"
            ;;
    esac
}

# Switch language function
switch_language() {
    # Get current layout before switching
    local old_layout=$(get_current_layout)
    
    # Use Hyprland's keyboard switching
    hyprctl switchxkblayout at-translated-set-2-keyboard next >/dev/null 2>&1
    
    # Small delay to ensure layout has switched
    sleep 0.1
    
    # Get the new layout and show notification
    local new_layout=$(get_current_layout)
    local new_full_name=$(get_full_name)
    
    # Only show notification if layout actually changed
    if [[ "$old_layout" != "$new_layout" ]]; then
        case "$new_layout" in
            "ENG")
                notify-send "Input Language" "🇺🇸 $new_full_name" -i input-keyboard -t 1500 -h string:x-canonical-private-synchronous:keyboard
                ;;
            "BEN")
                notify-send "Input Language" "🇧🇩 $new_full_name" -i input-keyboard -t 1500 -h string:x-canonical-private-synchronous:keyboard
                ;;
            "ARA")
                notify-send "Input Language" "🇸🇦 $new_full_name" -i input-keyboard -t 1500 -h string:x-canonical-private-synchronous:keyboard
                ;;
            *)
                notify-send "Input Language" "⌨️  $new_full_name" -i input-keyboard -t 1500 -h string:x-canonical-private-synchronous:keyboard
                ;;
        esac
    fi
}

# Handle arguments
case "$1" in
    "switch")
        switch_language
        ;;
    "toggle")
        switch_language
        ;;
    *)
        get_current_layout
        ;;
esac
