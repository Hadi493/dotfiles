# [Hadi Alam](https://github.com/Hadi493)'s Personal dotfiles

## Overview
This repository contains my personal configuration files (dotfiles) optimized for **Hyprland** on Linux.

## Key Components:
- **Window Manager:** [Hyprland](https://hyprland.org/) (≥ 0.56) with **Lua config** (`hyprland.lua`) and **scrolling layout** (niri-like)
- **Scrolloverview Plugin:** [scrolloverview](https://github.com/hyprwm/hyprland-plugins) for the overview mode
- **Status Bar:** [Waybar](https://github.com/Alexays/Waybar) (patched — see below)
- **Notification Daemon:** [SwayNC](https://github.com/ErikReider/SwayNotificationCenter)
- **On-Screen Display:** [SwayOSD](https://github.com/ErikReider/SwayOSD) (volume, mic, brightness OSD with `%` readout)
- **Launchers:** [Rofi](https://github.com/davatorium/rofi) (Wayland) & [Tofi](https://github.com/philj56/tofi)
- **Terminals:** [st](https://st.suckless.org/) (built from `st/` with the alpha patch, kitty/gruber-darker-ayu theme) & [Kitty](https://sw.kovidgoyal.net/kitty/)
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
| Overview navigate | `Super + i` / `Super + k` / `Super + h` / `Super + l` |

## Usage:
To deploy the configurations, use the provided `deploy` script:

```bash
./deploy [command]

# Show Help
./deploy -h

# Link all configurations (default)
./deploy all

# Auto-accept replacing existing files/dirs (no prompt)
./deploy -y all
```

If a destination already exists as a regular file or directory (not a symlink), `deploy`
asks for permission before replacing it, backing up the original to `~/.deploy-backup/`.

### Building st
`st` is a suckless terminal and must be compiled (it has no runtime config file). The
`st/` directory holds a `config.h` (Iosevka Term SS04, gruber-darker-ayu palette, 0.88
background opacity) plus the alpha patch. `./deploy st` clones st 0.8.5, patches it, and
installs to `~/.local/bin/st`:

```bash
./deploy st
```

### URL Launcher
`Super + U` opens a GTK4 keyboard-first Brave URL launcher
(`~/.config/hypr/scripts/url_launcher_gui.py`) that shows history, keeps a cache in
`~/.cache/url_launcher`, and closes itself after opening a URL.
