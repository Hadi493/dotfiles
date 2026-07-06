#!/bin/bash
OUTDIR="$HOME/Videos/screen-record"
mkdir -p "$OUTDIR"

if pgrep -x "ffmpeg" >/dev/null; then
    killall -INT ffmpeg
    twmnc -t "Recording" -c "Stopped" -d 2000
else
    FILE="$OUTDIR/recording_$(date +%Y-%m-%d_%H-%M-%S).mp4"
    ffmpeg -f x11grab -draw_mouse 0 -video_size $(xdpyinfo | awk '/dimensions/{print $2}') -i "$DISPLAY" -f pulse -i default "$FILE" &
    sleep 1
    twmnc -t "Recording" -c "Started" -d 2000
fi
