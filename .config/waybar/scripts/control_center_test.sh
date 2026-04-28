#!/bin/bash

# Simple test for control center
dunstify "Control Center" "Button clicked!" -i settings

# Simple menu test
selected=$(echo -e "🔊 Volume Control\n🔆 Brightness\n📶 Wi-Fi\n🔵 Bluetooth\n📅 Calendar\n⚙️ Settings\n──────────\n🔒 Lock Screen\n💤 Sleep\n🚪 Logout\n🔄 Reboot\n⏻ Shutdown" | rofi -dmenu -p "Control Center" -i)

case "$selected" in
    *"Volume"*) 
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.5
        dunstify "Volume" "Set to 50%" -i audio-volume-medium
        ;;
    *"Brightness"*)
        brightnessctl set 50%
        dunstify "Brightness" "Set to 50%" -i display-brightness
        ;;
    *"Wi-Fi"*)
        dunstify "Wi-Fi" "Opening network settings..." -i network-wireless
        ;;
    *"Bluetooth"*)
        dunstify "Bluetooth" "Opening bluetooth settings..." -i bluetooth
        ;;
    *"Calendar"*)
        dunstify "Calendar" "$(date)" -i calendar
        ;;
    *"Settings"*)
        dunstify "Settings" "Opening system settings..." -i preferences-system
        ;;
    *"Lock Screen"*)
        dunstify "System" "Locking screen..." -i system-lock-screen
        hyprlock
        ;;
    *"Sleep"*)
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Sleep system?")
        if [ "$confirm" = "Yes" ]; then
            dunstify "System" "Going to sleep..." -i system-suspend
            systemctl suspend
        fi
        ;;
    *"Logout"*)
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Logout from Hyprland?")
        if [ "$confirm" = "Yes" ]; then
            dunstify "System" "Logging out..." -i system-log-out
            hyprctl dispatch exit
        fi
        ;;
    *"Reboot"*)
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Reboot system?")
        if [ "$confirm" = "Yes" ]; then
            dunstify "System" "Rebooting..." -i system-reboot
            systemctl reboot
        fi
        ;;
    *"Shutdown"*)
        confirm=$(echo -e "Yes\nNo" | rofi -dmenu -p "Shutdown system?")
        if [ "$confirm" = "Yes" ]; then
            dunstify "System" "Shutting down..." -i system-shutdown
            systemctl poweroff
        fi
        ;;
esac