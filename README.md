# [Hadi Alam](https://github.com/Hadi493)'s Personal dotfiles

## Overview
Personal configuration files (dotfiles) for a lightweight **Hyprland** desktop on
Linux. `~/dotfiles` is the single source of truth: the session runs from this
tree directly, with no Ryoku, no Quickshell shell, and no display manager.

## Key components

- **Window manager:** [Hyprland](https://hyprland.org/) 0.57.x with a modular
  **Lua** config and the built-in **scrolling layout** (niri-like).
- **Session:** TTY login, then `start-hyprland` (or plain `Hyprland`). No SDDM
  or other display manager.
- **Bar:** system **Waybar** 0.16 (no patched build).
- **Notifications / OSD:** **swaync** — volume and mic feedback is sent
  as replace-in-place notifications.
- **Launchers:** [Rofi](https://github.com/davatorium/rofi) (drun) and
  [Tofi](https://github.com/philj56/tofi).
- **Lock / idle:** `hyprlock` + `hypridle`.
- **Screenshots:** `grim` + `slurp` (region or full monitor).
- **Clipboard:** `cliphist` + `wl-clipboard`.
- **Colour temperature:** `hyprsunset` (native Hyprland IPC).
- **External monitor:** DDC/CI via `ddcutil-service` (brightness, contrast,
  input switching).
- **Terminals:** [st](https://st.suckless.org/) (built from `st/` with the alpha
  patch) and [Kitty](https://sw.kovidgoyal.net/kitty/).
- **Editors:** [Neovim](https://neovim.io/), [Helix](https://helix-editor.com/),
  [Emacs](emacs.conf/README.md).
- **Shells:** [Fish](https://fishshell.com/), [Nushell](https://www.nushell.sh/),
  Bash.

## Configuration

The live Hyprland config is `~/dotfiles/.config/hypr/hyprland.lua`, split into
`conf/*.lua`. A plain `Hyprland` or `start-hyprland` launch reads
`~/.config/hypr/hyprland.lua`; `./deploy hypr` installs that path as a small
loader which points `package.path` at this repo and `dofile`s the real config:

```text
TTY login
  └─ start-hyprland          (or: Hyprland)
       └─ ~/.config/hypr/hyprland.lua      (loader installed by deploy)
            └─ ~/dotfiles/.config/hypr/hyprland.lua
                 └─ conf/{variables,startup,animations,input,theme,
                          window_rules,keybinds}.lua
```

No display manager is enabled. `~/.local/share/wayland-sessions/hadi-hyprland.desktop`
is installed for the day a display manager is used again; it is unused now.

```bash
# Verify the exact config Hyprland will load
Hyprland --verify-config --config ~/.config/hypr/hyprland.lua

# Reload the running session
hyprctl reload
```

> **Hyprland 0.57 bind note:** binds registered with a dispatcher table are
> silently dead — they show in `hyprctl binds` but never fire
> ([hyprwm/Hyprland#17425](https://github.com/hyprwm/Hyprland/issues/17425)).
> `conf/keybinds.lua` therefore wraps every dispatcher in a raw Lua function via
> its local `bind()` helper. Keep using that helper; do not add raw
> dispatcher-table binds.

The legacy `.conf` files in `.config/hypr/` were removed: Hyprland 0.57 only
loads the Lua tree, which is authoritative.

See [`.config/hypr/README.md`](.config/hypr/README.md) for the full key map,
startup sequence and requirements.

## Keybindings (most used)

Modifier is `Super`.

| Action | Keybinding |
|---|---|
| Terminal (`kitty herdr`) | `Super + Return` |
| Plain terminal | `Super + Shift + Return` |
| App launcher (Rofi drun) | `Super + D` |
| App launcher (Tofi) | `Super + Shift + A` |
| Cycle windows (global MRU) | `Alt + Tab` / `Alt + Shift + Tab` |
| Cycle windows in workspace | `Super + Tab` / `Super + Shift + Tab` |
| File manager | `Super + E` |
| Editor (Emacs) | `Super + C` |
| Browser | `Super + B` |
| Wallpaper picker | `Super + W` |
| Clipboard history / manage / password store | `Super + V` / `Super + Alt + V` / `Super + Shift + V` |
| Session app | `Super + S` |
| Close window | `Super + Q` |
| Toggle fullscreen | `Super + F` |
| Toggle floating | `Super + Space` |
| Lock screen | `Super + L` |
| Logout menu | `Super + Esc` |
| Toggle Waybar | `Ctrl + Esc` |
| Reload config | `Super + Shift + R` |
| Region / monitor screenshot | `Print` / `Shift + Print` |
| Volume down / up / mic mute | `F8` / `F9` / `F10` |
| Monitor brightness / colour temp | `F5`/`F6` / `F2` |

The function-key map and its caveats are documented in
[`.config/hypr/README.md`](.config/hypr/README.md#function-keys).

## Features

### Niri-like scrolling layout

Windows are arranged in infinitely scrolling columns using Hyprland's built-in
scrolling layout.

| Action | Keybinding |
|---|---|
| Focus column left/right | `Super + ←` / `Super + →` |
| Focus column up/down | `Super + Shift + ↑` / `Super + Shift + ↓` |
| Move window left/right | `Super + Shift + ←` / `Super + Shift + →` |
| Move window into previous/next column | `Super + ,` / `Super + .` |
| Swap column with neighbour | `Super + Shift + ,` / `Super + Shift + .` |
| Promote window to its own column | `Super + Shift + ]` |
| Resize column width | `Super + Alt + ,` / `Super + Alt + .` |
| Fit active column to viewport | `Super + \` |
| Scroll columns | `Super + scroll` |
| Swap column via scroll | `Super + Shift + scroll` |
| Resize column via scroll | `Super + Ctrl + scroll` |
| Resize window freely | `Super + Ctrl + arrows` |
| Switch workspace | `Super + ↑` / `Super + ↓` or `Alt + Shift + scroll` |
| Switch workspace (touchpad) | 3-finger horizontal swipe |
| Rotate active monitor | `Super + Alt + R` (`+ Shift` resets) |

## Usage

To deploy the configurations, use the provided `deploy` script:

```bash
./deploy [command]

# Show help
./deploy -h

# Link all configurations (default)
./deploy all

# Auto-accept replacing existing files/dirs (no prompt)
./deploy -y all
```

For the desktop specifically:

```bash
./deploy hypr            # loader in ~/.config/hypr + session entry
./deploy waybar          # bar config
./deploy swaync          # notification config + enable swaync.service
```

If a destination already exists as a regular file or directory (not a symlink),
`deploy` asks for permission before replacing it, backing up the original to
`~/.deploy-backup/`.

### Building st

`st` is a suckless terminal and must be compiled (it has no runtime config
file). The `st/` directory holds a `config.h` (Iosevka Term SS04, gruber-darker-ayu
palette, 0.88 background opacity) plus the alpha patch. `./deploy st` clones
st 0.8.5, patches it, and installs to `~/.local/bin/st`:

```bash
./deploy st
```

### URL launcher

`Super + U` opens a GTK4 keyboard-first Brave URL launcher
(`~/.config/hypr/scripts/url_launcher_gui.py`) that shows history, keeps a cache
in `~/.cache/url_launcher`, and closes itself after opening a URL.
