#!/bin/bash

ROFI_THEME="
* {
    bg-col: #181818;
    fg-col: #ffffff;
    blue: #6DCFFF;
    grey: #6B7B8E;
    font: \"Iosevka Nerd Font 12\";
}

window {
    border: 2px;
    border-color: @blue;
    background-color: @bg-col;
}

mainbox {
    background-color: @bg-col;
}

inputbar {
    background-color: @bg-col;
}

prompt {
    background-color: @blue;
    text-color: @bg-col;
    padding: 6px;
    border-radius: 3px;
}

entry {
    text-color: @fg-col;
    background-color: @bg-col;
}

listview {
    background-color: @bg-col;
}

element {
    background-color: @bg-col;
    text-color: @fg-col;
}

element-icon {
    size: 25px;
}
"

if command -v swaync-client &> /dev/null; then
    swaync-client -t -sw
elif command -v dunstctl &> /dev/null; then
    dunstctl history-pop
else
    journalctl --user -n 10 --no-pager | rofi -dmenu -p "System Messages" -theme-str "$ROFI_THEME"
fi
