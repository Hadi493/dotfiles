#!/bin/bash

# Power Menu Script
# Beautiful power options with confirmations

# Rofi theme matching your waybar
ROFI_THEME="
* {
    bg-col: #1e1e2e;
    bg-col-light: #313244;
    border-col: #f38ba8;
    selected-col: #45475a;
    red: #f38ba8;
    blue: #89b4fa;
    fg-col: #cdd6f4;
    fg-col2: #f38ba8;
    grey: #6c7086;
    width: 300;
    font: \"Iosevka Nerd Font 14\";
}

window {
    height: 300px;
    border: 2px;
    border-color: @red;
    background-color: @bg-col;
}

mainbox {
    background-color: @bg-col;
}

inputbar {
    children: [prompt,entry];
    background-color: @bg-col;
    border-radius: 5px;
    padding: 2px;
}

prompt {
    background-color: @red;
    padding: 6px;
    text-color: @bg-col;
    border-radius: 3px;
    margin: 20px 0px 0px 20px;
}

entry {
    padding: 6px;
    margin: 20px 0px 0px 10px;
    text-color: @fg-col;
    background-color: @bg-col;
}

listview {
    border: 0px 0px 0px;
    padding: 6px 0px 0px;
    margin: 10px 0px 0px 20px;
    columns: 1;
    lines: 5;
    background-color: @bg-col;
}

element {
    padding: 12px;
    background-color: @bg-col;
    text-color: @fg-col;
    font-size: 16px;
}

element-icon {
    size: 25px;
}

element selected {
    background-color: @selected-col;
    text-color: @fg-col2;
}
"

# Show power menu
selected=$(echo -e "🔒 Lock Screen\n💤 Sleep\n🚪 Logout\n🔄 Reboot\n⏻ Shutdown" | rofi -dmenu -p "Power Menu" -theme-str "$ROFI_THEME")

case "$selected" in
    *"Lock Screen")
        dunstify "System" "Locking screen..." -i system-lock-screen
        hyprlock
        ;;
    *"Sleep")
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Sleep system?" -theme-str "$ROFI_THEME")
        if [ "$confirm" = "Yes" ]; then
            dunstify "System" "Going to sleep..." -i system-suspend
            systemctl suspend
        fi
        ;;
    *"Logout")
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Logout from Hyprland?" -theme-str "$ROFI_THEME")
        if [ "$confirm" = "Yes" ]; then
            dunstify "System" "Logging out..." -i system-log-out
            hyprctl dispatch exit
        fi
        ;;
    *"Reboot")
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Reboot system?" -theme-str "$ROFI_THEME")
        if [ "$confirm" = "Yes" ]; then
            dunstify "System" "Rebooting..." -i system-reboot
            systemctl reboot
        fi
        ;;
    *"Shutdown")
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Shutdown system?" -theme-str "$ROFI_THEME")
        if [ "$confirm" = "Yes" ]; then
            dunstify "System" "Shutting down..." -i system-shutdown
            systemctl poweroff
        fi
        ;;
esac