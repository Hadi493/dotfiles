# [Hadi Alam](https://github.com/Hadi493)'s Personal dotfiles

## Overview
This repository contains my personal configuration files (dotfiles) optimized for **Hyprland** on Linux.

## Key Components:
- **Window Manager:** [Hyprland](https://hyprland.org/) with **scrolling layout** (niri-like)
- **Status Bar:** [Waybar](https://github.com/Alexays/Waybar)
- **Notification Daemon:** [SwayNC](https://github.com/ErikReider/SwayNotificationCenter)
- **Launchers:** [Rofi](https://github.com/davatorium/rofi) (Wayland) & [Tofi](https://github.com/philj56/tofi)
- **Terminal:** [Kitty](https://sw.kovidgoyal.net/kitty/)
- **Editors:** [Neovim](https://neovim.io/), [Helix](https://helix-editor.com/), [Emacs](emacs.conf/README.md)
- **Shells:** [Fish](https://fishshell.com/), [Nushell](https://www.nushell.sh/), Bash

## Features:

### Niri-like Scrolling Layout
Windows are arranged in an infinitely scrolling column using Hyprland's built-in scrolling layout.

| Action | Keybinding |
|---|---|
| Navigate columns | `Super + ,` / `Super + .` |
| Navigate columns (wrap) | `Super + ←` / `Super + →` |
| Swap column with neighbor | `Super + Shift + ,` / `Super + Shift + .` |
| Promote window to new column | `Super + Shift + ]` |
| Resize column (presets) | `Super + Alt + ,` / `Super + Alt + .` |
| Fit column to viewport | `Super + \` |
| Scroll columns | `Super + scroll` |
| Swap column via scroll | `Super + Shift + scroll` |
| Resize column via scroll | `Super + Ctrl + scroll` |
| Switch workspace | `Alt + scroll` |
| Switch workspace (touchpad) | 3-finger swipe left/right |
| Overview | `Super + S` |

## Usage:
To deploy the configurations, use the provided `deploy` script:

```bash
./deploy [command]

# Show Help
./deploy -h

# Link all configurations (default)
./deploy all
```
