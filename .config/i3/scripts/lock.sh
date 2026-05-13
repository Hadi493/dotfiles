#!/usr/bin/env bash

# --- Dracula Theme Colors ---
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

# --- Font Settings ---
# We use Iosevka SS04 as found on the system earlier
FONT="Iosevka SS04"

i3lock \
  --color=$BACKGROUND \
  \
  --insidever-color=$BACKGROUND'00' \
  --ringver-color=$CYAN'ff' \
  \
  --insidewrong-color=$BACKGROUND'00' \
  --ringwrong-color=$RED'ff' \
  \
  --inside-color=$BACKGROUND'00' \
  --ring-color=$PURPLE'ff' \
  --line-color=$BACKGROUND'00' \
  --separator-color=$SELECTION'ff' \
  \
  --verif-color=$CYAN'ff' \
  --wrong-color=$RED'ff' \
  --layout-color=$FOREGROUND'ff' \
  \
  --keyhl-color=$PINK'ff' \
  --bshl-color=$ORANGE'ff' \
  \
  --screen=1 \
  --blur=10 \
  --clock \
  --indicator \
  \
  --time-str="%H:%M" \
  --time-font="$FONT" \
  --time-size=120 \
  --time-color=$FOREGROUND'ff' \
  \
  --date-str="%A, %B %d" \
  --date-font="$FONT" \
  --date-size=24 \
  --date-color=$COMMENT'ff' \
  \
  --greeter-text="Locked" \
  --greeter-font="$FONT" \
  --greeter-size=18 \
  --greeter-color=$PURPLE'ff' \
  \
  --verif-text="Verifying..." \
  --wrong-text="Try Again" \
  \
  --radius=120 \
  --ring-width=8 \
  --pass-media-keys \
  --pass-screen-keys \
  --pass-volume-keys \
  "$@"
