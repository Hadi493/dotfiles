#!/bin/bash

# Control Center Script for Waybar
# Beautiful quick settings menu

# Define colors for theming (you can adjust these to match your waybar theme)
ROFI_THEME="
* {
    bg-col: #1e1e2e;
    bg-col-light: #313244;
    border-col: #89b4fa;
    selected-col: #45475a;
    blue: #89b4fa;
    fg-col: #cdd6f4;
    fg-col2: #f38ba8;
    grey: #6c7086;
    width: 400;
    font: \"JetBrains Mono 12\";
}

element-text, element-icon , mode-switcher {
    background-color: inherit;
    text-color: inherit;
}

window {
    height: 500px;
    border: 2px;
    border-color: @border-col;
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
    background-color: @blue;
    padding: 6px;
    text-color: @bg-col;
    border-radius: 3px;
    margin: 20px 0px 0px 20px;
}

textbox-prompt-colon {
    expand: false;
    str: \":\";
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
    lines: 8;
    background-color: @bg-col;
}

element {
    padding: 8px;
    background-color: @bg-col;
    text-color: @fg-col;
}

element-icon {
    size: 25px;
}

element selected {
    background-color: @selected-col;
    text-color: @fg-col2;
}

mode-switcher {
    spacing: 0;
}

button {
    padding: 10px;
    background-color: @bg-col-light;
    text-color: @grey;
    vertical-align: 0.5; 
    horizontal-align: 0.5;
}

button selected {
    background-color: @bg-col;
    text-color: @blue;
}
"

# Functions for each control option
wifi_toggle() {
    if nmcli radio wifi | grep -q enabled; then
        nmcli radio wifi off
        dunstify "Wi-Fi" "Disabled" -i network-wireless-offline
    else
        nmcli radio wifi on
        dunstify "Wi-Fi" "Enabled" -i network-wireless
    fi
}

wifi_connect() {
    # Launch network manager GUI or rofi wifi menu
    if command -v nm-connection-editor &> /dev/null; then
        nm-connection-editor
    else
        dunstify "Network Manager" "GUI not available. Install nm-connection-editor"
    fi
}

bluetooth_toggle() {
    if bluetoothctl show | grep -q "Powered: yes"; then
        bluetoothctl power off
        dunstify "Bluetooth" "Disabled" -i bluetooth-disabled
    else
        bluetoothctl power on
        dunstify "Bluetooth" "Enabled" -i bluetooth
    fi
}

notifications_center() {
    # Check if swaync is available, otherwise use dunst history
    if command -v swaync-client &> /dev/null; then
        swaync-client -t
    elif command -v dunstctl &> /dev/null; then
        dunstctl history-pop
    else
        dunstify "Notifications" "No notification daemon found"
    fi
}

brightness_control() {
    current=$(brightnessctl get)
    max=$(brightnessctl max)
    percent=$(( (current * 100) / max ))
    
    new_brightness=$(echo -e "10%\n25%\n50%\n75%\n100%" | rofi -dmenu -p "Brightness ($percent%)" -theme-str "$ROFI_THEME")
    
    if [ -n "$new_brightness" ]; then
        brightnessctl set "$new_brightness"
        dunstify "Brightness" "Set to $new_brightness" -i display-brightness
    fi
}

volume_control() {
    current=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')
    
    action=$(echo -e "🔇 Mute\n🔉 25%\n🔊 50%\n🔊 75%\n🔊 100%" | rofi -dmenu -p "Volume ($current%)" -theme-str "$ROFI_THEME")
    
    case "$action" in
        *"Mute") wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
        *"25%") wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.25 ;;
        *"50%") wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.50 ;;
        *"75%") wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.75 ;;
        *"100%") wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0 ;;
    esac
}

calendar_todo() {
    # Simple calendar and todo viewer
    today=$(date '+%A, %B %d, %Y')
    cal_output=$(cal -m)
    
    todo_file="$HOME/.config/waybar/todo.txt"
    [ ! -f "$todo_file" ] && touch "$todo_file"
    
    todo_list=$(cat "$todo_file" 2>/dev/null || echo "No todos yet!")
    
    message="📅 $today\n\n$cal_output\n\n📝 TODO:\n$todo_list"
    
    action=$(echo -e "View Calendar\nAdd TODO\nEdit TODO File" | rofi -dmenu -p "Calendar & TODO" -theme-str "$ROFI_THEME")
    
    case "$action" in
        "View Calendar") 
            echo -e "$message" | rofi -dmenu -p "Calendar" -theme-str "$ROFI_THEME" -markup-rows
            ;;
        "Add TODO")
            new_todo=$(echo "" | rofi -dmenu -p "Add TODO:" -theme-str "$ROFI_THEME")
            if [ -n "$new_todo" ]; then
                echo "• $new_todo" >> "$todo_file"
                dunstify "TODO" "Added: $new_todo" -i text-editor
            fi
            ;;
        "Edit TODO File")
            ${EDITOR:-nano} "$todo_file"
            ;;
    esac
}

system_controls() {
    action=$(echo -e "🔒 Lock Screen\n💤 Sleep\n🚪 Logout\n🔄 Reboot\n⏻ Shutdown\n──────────\n🔄 Restart Waybar\n🎨 Change Wallpaper\n⚙️ System Settings" | rofi -dmenu -p "System Controls" -theme-str "$ROFI_THEME")
    
    case "$action" in
        *"Lock Screen") 
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
        *"Restart Waybar") 
            killall waybar && waybar & 
            ;;
        *"Change Wallpaper") 
            ~/.config/hypr/scripts/wallpaper_select.sh 
            ;;
        *"System Settings") 
            if command -v gnome-control-center &> /dev/null; then
                gnome-control-center
            else
                dunstify "Settings" "No settings app found"
            fi
            ;;
    esac
}

# Main menu
show_control_center() {
    # Get system status for display
    wifi_status=$(nmcli radio wifi | grep -q enabled && echo "📶 Wi-Fi: ON" || echo "📵 Wi-Fi: OFF")
    bluetooth_status=$(bluetoothctl show | grep -q "Powered: yes" && echo "🔵 Bluetooth: ON" || echo "⚫ Bluetooth: OFF")
    volume_status="🔊 Volume: $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}')%"
    brightness_status="☀️ Brightness: $(( ($(brightnessctl get) * 100) / $(brightnessctl max) ))%"
    
    # Create menu with current status
    menu="$wifi_status|wifi
🌐 Wi-Fi Settings|wifi_settings
$bluetooth_status|bluetooth
🔔 Notifications|notifications
$volume_status|volume
$brightness_status|brightness
📅 Calendar & TODO|calendar
⚙️ System Controls|system"
    
    selected=$(echo "$menu" | rofi -dmenu -sep '|' -p "Control Center" -theme-str "$ROFI_THEME" -format 'i:s' | cut -d: -f2 | cut -d'|' -f2)
    
    case "$selected" in
        "wifi") wifi_toggle ;;
        "wifi_settings") wifi_connect ;;
        "bluetooth") bluetooth_toggle ;;
        "notifications") notifications_center ;;
        "volume") volume_control ;;
        "brightness") brightness_control ;;
        "calendar") calendar_todo ;;
        "system") system_controls ;;
    esac
}

# Run the control center
show_control_center