#!/bin/bash
# audio.sh - JSON output for dock volume module (pulseaudio/pipewire)
get_vol() {
    pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | awk -F'/' '/Volume/{gsub(/[% ]/,"",$2); print $2}'
}
get_muted() {
    pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -q "yes" && echo muted || echo unmuted
}

vol=$(get_vol)
muted=$(get_muted)

if [ "$muted" = "muted" ] || [ -z "$vol" ]; then
    echo '{"text":"󰝟","tooltip":"Muted","class":"muted"}'
    exit 0
fi

if [ "$vol" -le 33 ]; then
    icon="󰕿"
elif [ "$vol" -le 66 ]; then
    icon="󰖀"
else
    icon="󰕾"
fi
echo "{\"text\":\"$icon $vol%\",\"tooltip\":\"Volume $vol%\"}"
