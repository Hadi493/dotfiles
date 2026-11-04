# [Hadi Alam](https://github.com/Hadi493)'s Personal dotfiles

## Overview
This repository contains my personal configuration files (dotfiles) optimized for **Hyprland** on Linux.

## Key Components:
- **Window Manager:** [Hyprland](https://hyprland.org/) (≥ 0.57) with **Ryoku's Lua config** (`~/.config/hypr/modules/*.lua`) and **scrolling layout** (niri-like)
- **Overview & switcher:** Ryoku's own surfaces — `Super+Tab` workspace expo (`ryoku:overview`) and `Alt+Tab` MRU window switcher (`ryoku:switcher`). The old scrolloverview plugin is not loaded.
- **Shell/Bar/Notifications/OSD/Clipboard:** **Shima** (Ryoku's Quickshell `shell`) — the only OSD for volume, mic, media and brightness
- **Launchers:** [Rofi](https://github.com/davatorium/rofi) (Wayland) & [Tofi](https://github.com/philj56/tofi)
- **Terminals:** [st](https://st.suckless.org/) (built from `st/` with the alpha patch, kitty/gruber-darker-ayu theme) & [Kitty](https://sw.kovidgoyal.net/kitty/)
- **Editors:** [Neovim](https://neovim.io/), [Helix](https://helix-editor.com/), [Emacs](emacs.conf/README.md)
- **Shells:** [Fish](https://fishshell.com/), [Nushell](https://www.nushell.sh/), Bash

## Configuration
The live Hyprland config is managed by **Ryoku**: `~/.config/hypr/modules/*.lua`, with
personal overrides in `~/.config/ryoku/user_edits/hypr/modules/*.lua`. Hyprland 0.57
dropped the legacy `.conf` format, so Lua is the only loaded config.

The older Lua tree in this repo (`.config/hypr/hyprland.lua` + `conf/*.lua`) is kept for
reference only and is not deployed: `./deploy` deliberately skips `~/.config/hypr`.

### Shima Shell
Shima (the Quickshell `shell` instance, `qs -c shell`) provides the bar, notifications,
OSD, launcher and clipboard. It is the only OSD renderer; SwayOSD or Noctalia's OSD
must not run alongside it. Key bindings:

- `Super + V` — clipboard (`ryoku:clipboard`)
- `Super + D` — launcher (`ryoku:launcher`)
- `Alt + Tab` / `Alt + Shift + Tab` — window switcher, most recently used first
  (`ryoku:switcher` forward, `ryoku:switcher-prev` back)
- `Super + Tab` / `Super + Alt + Tab` — workspace overview (`ryoku:overview`). While
  it is open, `Super + Tab` steps the selection instead of closing it, and
  `Super + Shift + Tab` (`ryoku:overview-prev`) steps it back; `Esc` dismisses.
- `Super + N` / `Super + Esc` — quick settings
- `Ctrl + Esc` — toggle bar (`ryoku:barToggle`)
- Volume/mic/media keys — `qs -c shell ipc call audio ...`, `input-mute-toggle`, `mpris ...` + `osd media ...`
- Brightness (`F5`/`F6`, `XF86MonBrightness*`) — `qs -c shell ipc call brightness increment|decrement`

`qs -c shell ipc call osd volume` only redraws the OSD; it does not change the sink.
Ryoku Shot (`ryoku-cmd-ryoshot`) handles screenshots: `Print` selects a region,
`Shift+Print` captures the whole monitor, and `Super+Shift+S` opens annotate/beautify.
Color picking uses `ryoku-cmd-color-picker`. See `.config/hypr/README.md` for the
full key map and the duplicate-OSD note.

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
