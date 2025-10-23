#!/usr/bin/env bash
# Gracefully restart hypridle
if pgrep -x hypridle >/dev/null; then
    pkill -x hypridle
    sleep 0.5
fi
bash systemctl --user enable --now hypridle
hypridle &
disown
