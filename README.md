# [Hadi Alam](https://github.com/Hadi493)'s Personal dotfiles

## Overview
This repository contains my personal configuration files (dotfiles) optimized for **Hyprland** on Linux.

## Key Components:
- **Window Manager:** [Hyprland](https://hyprland.org/) (≥ 0.56) with **Lua config** (`hyprland.lua`) and **scrolling layout** (niri-like)
- **Scrolloverview Plugin:** [scrolloverview](https://github.com/hyprwm/hyprland-plugins) for the overview mode
- **Status Bar:** [Waybar](https://github.com/Alexays/Waybar) (patched — see below)
- **Notification Daemon:** [SwayNC](https://github.com/ErikReider/SwayNotificationCenter)
- **Launchers:** [Rofi](https://github.com/davatorium/rofi) (Wayland) & [Tofi](https://github.com/philj56/tofi)
- **Terminal:** [Kitty](https://sw.kovidgoyal.net/kitty/)
- **Editors:** [Neovim](https://neovim.io/), [Helix](https://helix-editor.com/), [Emacs](emacs.conf/README.md)
- **Shells:** [Fish](https://fishshell.com/), [Nushell](https://www.nushell.sh/), Bash

## Configuration
The Hyprland config is written in **Lua** (`~/.config/hypr/hyprland.lua` + modular `conf/*.lua` files),
which is the only supported config format since Hyprland 0.57 (0.56.1 warns on the legacy
`.conf` format). The old `.conf` files are kept only as a reference and are **not loaded**.

### Patched Waybar
Waybar ≤ 0.15.0 hardcodes `hyprctl dispatch workspace <id>` for workspace clicks, which the
Hyprland Lua config manager rejects. This repo relies on a patched Waybar
(`~/.local/bin/waybar`) whose `hyprland/workspaces` module sends the Lua-valid form
(`dispatch hl.dsp.focus({ workspace = "<id>" })`). Rebuild after any Waybar update:

```bash
git clone --branch 0.15.0 --depth 1 https://github.com/Alexays/Waybar /tmp/waybar
cd /tmp/waybar
# apply the workspace-click patch (src/modules/hyprland/workspace.cpp)
meson setup build -Dcava=disabled --prefix="$HOME/.local"
ninja -C build install
```

## Features:

### Niri-like Scrolling Layout
Windows are arranged in an infinitely scrolling column using Hyprland's built-in scrolling layout.

| Action | Keybinding |
|---|---|
| Navigate columns (focus l/r) | `Super + ←` / `Super + →` |
| Navigate columns (move ±col, wrap) | `Super + ,` / `Super + .` |
| Focus column above/below | `Super + ↑` / `Super + ↓` |
| Move window to other column | `Super + Shift + ←` / `Super + Shift + →` |
| Swap column with neighbor | `Super + Shift + ,` / `Super + Shift + .` |
| Promote window to new column | `Super + Shift + ]` |
| Resize column (presets) | `Super + Alt + ,` / `Super + Alt + .` |
| Fit column to viewport | `Super + \` |
| Scroll columns | `Super + scroll` |
| Swap column via scroll | `Super + Shift + scroll` |
| Resize column via scroll | `Super + Ctrl + scroll` |
| Switch workspace | `Alt + scroll` |
| Switch workspace (touchpad) | 3-finger swipe left/right |
| Overview toggle | `Super + S` |
| Overview select | `Super + Return` |
| Overview navigate | `Super + H` / `Super + J` / `Super + K` / `Super + L` |

## Usage:
To deploy the configurations, use the provided `deploy` script:

```bash
./deploy [command]

# Show Help
./deploy -h

# Link all configurations (default)
./deploy all
```
