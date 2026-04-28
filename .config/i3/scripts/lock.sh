#!/usr/bin/env bash

BACKGROUND="282a36"
SELECTION="44475a"
FOREGROUND="f8f8f2"
COMMENT="6272a4"
CYAN="8be9fd"
GREEN="50fa7b"
ORANGE="ffb86c"
PINK="ff79c6"
PURPLE="bd93f9"
RED="ff5555"
YELLOW="f1fa8c"

i3lock \
    --insidever-color=$BACKGROUND'ff' \
    --ringver-color=$PURPLE'ff' \
    \
    --insidewrong-color=$BACKGROUND'ff' \
    --ringwrong-color=$RED'ff' \
    \
    --inside-color=$BACKGROUND'ff' \
    --ring-color=$SELECTION'ff' \
    --line-color=$BACKGROUND'00' \
    --separator-color=$SELECTION'ff' \
    \
    --verif-color=$FOREGROUND'ff' \
    --wrong-color=$RED'ff' \
    --layout-color=$FOREGROUND'ff' \
    \
    --keyhl-color=$GREEN'ff' \
    --bshl-color=$RED'ff' \
    \
    --screen=1 \
    --blur=9 \
    --clock \
    --indicator \
    --time-str="%I:%M:%S %p" \
    \
    --date-str="%A, %d %B %Y" \
    --time-color=$FOREGROUND'ff' \
    --date-color=$FOREGROUND'ff' \
    --radius=250 \
    --ring-width=10 \
    --time-font="Iosevka Term SS04" \
    --date-font="Iosevka Term SS04" \
    --layout-font="Iosevka SS04" \
    --verif-font="Iosevka SS04" \
    --wrong-font="Iosevka SS04" \
    --greeter-font="Iosevka SS04" \
    --time-size=70 \
    --date-size=24 \
    --layout-size=60 \
    --verif-size=50 \
    --wrong-size=50 \
    --greeter-size=50 \
    "$@"
