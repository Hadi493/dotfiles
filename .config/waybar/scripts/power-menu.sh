#!/bin/bash

chosen=$(printf " Shutdown\n Reboot\n Suspend\n Logout" | rofi -dmenu -i -p "Power")

case "$chosen" in
    " Shutdown") systemctl poweroff ;;
    " Reboot") systemctl reboot ;;
    " Suspend") systemctl suspend ;;
    " Logout") 
        if command -v hyprctl &> /dev/null; then
            hyprctl dispatch exit
        elif command -v pkill &> /dev/null; then
            pkill -KILL -u $USER
        fi
        ;;
esac
