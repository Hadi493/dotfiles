#!/bin/bash
# network.sh - JSON output for dock network module
if nmcli -t -f WIFI g 2>/dev/null | grep -q "enabled"; then
    if ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2); then
        if [ -n "$ssid" ]; then
            sig=$(nmcli -f SIGNAL -t dev wifi 2>/dev/null | head -1)
            echo "{\"text\":\"󰖩 $sig%\",\"tooltip\":\"$ssid\"}"
            exit 0
        fi
    fi
fi
if nmcli -t -f device,type,state device 2>/dev/null | grep -q "ethernet:connected"; then
    echo '{"text":"󰈀","tooltip":"Ethernet"}'
    exit 0
fi
echo '{"text":"󰖪","tooltip":"Disconnected","class":"disconnected"}'
