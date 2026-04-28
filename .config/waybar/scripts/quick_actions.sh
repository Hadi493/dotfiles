#!/bin/bash

# Quick Actions Menu - Alternative to full control center
# Provides most common actions in a simple menu

selected=$(echo -e "🔊 Volume 25%\n🔊 Volume 50%\n🔊 Volume 75%\n🔊 Volume 100%\n🔇 Mute Toggle\n──────────\n🔆 Brightness 25%\n🔆 Brightness 50%\n🔆 Brightness 75%\n🔆 Brightness 100%\n──────────\n📶 WiFi Toggle\n🔵 Bluetooth Toggle\n──────────\n🔒 Lock Screen\n💤 Sleep\n🚪 Logout" | rofi -dmenu -p "Quick Actions" -i)

case "$selected" in
    *"Volume 25%") wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.25 && dunstify "Volume" "Set to 25%" -i audio-volume-low ;;
    *"Volume 50%") wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.50 && dunstify "Volume" "Set to 50%" -i audio-volume-medium ;;
    *"Volume 75%") wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.75 && dunstify "Volume" "Set to 75%" -i audio-volume-high ;;
    *"Volume 100%") wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0 && dunstify "Volume" "Set to 100%" -i audio-volume-high ;;
    *"Mute Toggle") 
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED"; then
            dunstify "Volume" "Muted" -i audio-volume-muted
        else
            dunstify "Volume" "Unmuted" -i audio-volume-medium
        fi
        ;;
    *"Brightness 25%") brightnessctl set 25% && dunstify "Brightness" "Set to 25%" -i display-brightness ;;
    *"Brightness 50%") brightnessctl set 50% && dunstify "Brightness" "Set to 50%" -i display-brightness ;;
    *"Brightness 75%") brightnessctl set 75% && dunstify "Brightness" "Set to 75%" -i display-brightness ;;
    *"Brightness 100%") brightnessctl set 100% && dunstify "Brightness" "Set to 100%" -i display-brightness ;;
    *"WiFi Toggle")
        if nmcli radio wifi | grep -q enabled; then
            nmcli radio wifi off && dunstify "WiFi" "Disabled" -i network-wireless-offline
        else
            nmcli radio wifi on && dunstify "WiFi" "Enabled" -i network-wireless
        fi
        ;;
    *"Bluetooth Toggle")
        if bluetoothctl show | grep -q "Powered: yes"; then
            bluetoothctl power off && dunstify "Bluetooth" "Disabled" -i bluetooth-disabled
        else
            bluetoothctl power on && dunstify "Bluetooth" "Enabled" -i bluetooth
        fi
        ;;
    *"Lock Screen") hyprlock ;;
    *"Sleep") systemctl suspend && dunstify "System" "Going to sleep..." -i system-suspend ;;
    *"Logout") hyprctl dispatch exit ;;
esac