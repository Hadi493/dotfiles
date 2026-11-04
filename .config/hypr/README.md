# Hadi Alam's Personal hyprland config

> **Archived (Nov 2026):** Ryoku now owns `~/.config/hypr`. The keybindings from
> this tree were ported to Ryoku's overlay at
> `~/.config/ryoku/user_edits/hypr/modules/binds.lua`, and the supporting
> scripts/shaders were copied into `~/.config/hypr/`. `~/dotfiles/deploy` no
> longer links this directory; it is kept for reference only.

## Live config: Ryoku + Shima

The live compositor config is Ryoku's `~/.config/hypr/modules/binds.lua`
(personal changes in `~/.config/ryoku/user_edits/hypr/modules/binds.lua`).
`hyprland.lua` and `conf/*.lua` here are not loaded any more; the `.conf`
keybinds are kept in sync as reference only, since Hyprland 0.57 dropped the
legacy format.

**Shima** (the Quickshell `shell` instance) owns the bar, the OSD and media
feedback. Bind the IPC call that performs the action, not the display-only OSD:

| Action | Command |
| --- | --- |
| Volume up / down / mute (`XF86Audio*`, `F8`/`F9`, `SUPER+M`) | `qs -c shell ipc call audio volumeUp` / `volumeDown` / `mute` |
| Mic mute (`F10`, `XF86AudioMicMute`) | `~/.config/hypr/scripts/input-mute-toggle` (calls `osd mic`) |
| Media (`F11`, `XF86AudioNext` / `Prev` / `Play` / `Pause`) | `qs -c shell ipc call mpris <action>` + `qs -c shell ipc call osd media <action>` |
| Brightness (`F5`/`F6`, `XF86MonBrightness*`) | `qs -c shell ipc call brightness decrement` / `increment` |

`qs -c shell ipc call osd volume` only redraws the OSD; it never changes the
PipeWire sink, so it must not be bound to the volume keys.

### Ryoku-native tools

The live bindings use Ryoku's tools instead of standalone equivalents:

| Key | Tool |
| --- | --- |
| `Print` / `Super+Print` / `Super+Shift+S` | `ryoku-cmd-ryoshot` (region; annotate, beautify, OCR/search/record) |
| `Shift+Print` | `env RYOSHOT_MODE=monitor ryoku-cmd-ryoshot` (whole monitor) |
| `Super+P` / `Super+Shift+C` | `ryoku-cmd-color-picker` |
| `F3` | `qs -c shell ipc call brightness set 100` |
| `Super+Shift+A` | `ryoku:launcher` (replaces `tofi-drun`) |

`flameshot` and `hyprshot` are no longer used. Ryoku Shot handles region/window
snapping, annotation, beautify, OCR and recording in one UI.

If a volume or mic change paints **two** OSDs, the shared `ryoku-osd` window is
painting next to Iris's own island. `styleOwnsFeedback` in
`~/.config/quickshell/shell/services/Config.qml` must keep its `iris` branch
(that file is Ryoku-owned and outside this repo).

This is a modularized Hyprland configuration written in **Lua** (`hyprland.lua` + `conf/*.lua`).

> **Note:** Since Hyprland 0.57 the legacy `.conf` format is unsupported (0.56.1 warns about it).
> This config requires Hyprland ≥ 0.56.1 and loads entirely from Lua.

### Requirements:
This configuration depends on a variety of packages to be fully functional. Here is a list of the required software:

#### Core Compositor & Utilities
- **`hyprland`** (≥ 0.56.1): The Wayland compositor itself.
- **Ryoku workspace overview** (`SUPER+Tab` / `ALT+Tab` / top-left hotcorner): grid of all open windows and workspaces. (scrolloverview/hyprexpo plugins currently unusable on Hyprland 0.56.2 — recipes kept in git history.)
- **`hypridle`**: The idle management daemon for Hyprland.
- **`hyprlock`**: The screen locker for Hyprland.
- **`ryoku-cmd-ryoshot`** (Ryoku Shot): screenshots and annotation; replaces
  `flameshot` / `hyprshot`. `Print` selects a region, `Shift+Print` captures a
  monitor, `Super+Shift+S` opens the annotate/beautify UI.
- **`hyprpicker`**: Color picker backend; the bind uses Ryoku's
  `ryoku-cmd-color-picker` wrapper (notifies and keeps the clipboard selection).
- **`grim`**: Low-level capture used by Ryoku Shot/OCR and the "zoom into
  clipboard" bind (`ryoku-cmd-grim`).

#### System & Session Management
- **`xdg-desktop-portal-hyprland`**: Backend for xdg-desktop-portal, necessary for screen sharing and other integrations.
- **`pipewire`** & **`wireplumber`**: For audio management (`wpctl`).
- **`systemd`**: Provides `loginctl` and `systemctl` for session and power management.
- **`dbus`**: For inter-process communication.
- **`quickshell`** (Shima `shell`): the live bar and the only OSD for volume,
  brightness, mic and media. The old `swayosd` / Noctalia OSDs are not used.
- **`fcitx5`** (optional): input method. Fish exports the correct `fcitx` modules
  (`GTK_IM_MODULE`/`QT_IM_MODULE`/`XMODIFIERS`) only when the binary is installed;
  it is absent on this machine, so those vars stay unset.

#### Bars, Launchers & Notifications
- **`waybar`** (**patched**, see below): A highly customizable Wayland status bar.
- **`rofi`**: A versatile application launcher and menu generator.
- **`tofi`**: Another application launcher.
- **`swaync`**: A Wayland notification center.
- **`wlogout`**: A logout menu.
- **`walker`**: An application launcher.
- **`elephant`**: A helper for `walker`.

#### Clipboard Management
- **`wl-clipboard`**: Provides `wl-paste` and `wl-copy` for command-line clipboard access.
- **`cliphist`**: A clipboard history manager.

#### Theming & Visuals
- **`swaybg`**: A wallpaper manager for Wayland.
- **`imagemagick`**: Used by `set_wallpaper` to cache/scale wallpapers.
- **`nerd-font`**: A font for icons and symbols to display correctly.

#### Hardware & Media Control
- **`brightnessctl`**: For controlling screen brightness.
- **`playerctl`**: For controlling media players.
- **`wl-gammarelay-rs`**: Color temperature adjustment daemon.

#### Applications
- **`kitty`**: A GPU-accelerated terminal emulator.
- **`emacs`**: A text editor.
- **`nautilus`**: A file manager.
- **`discord`**: A Discord client.
- **`brave`**: Web browser (also used for app-style web shortcuts).

#### Other Tools
- **`wayland-boomer`**: A tool for zoom-in.
- **`cg-timer`**: A timer application. (personal)
- **`mpvpaper`**: For animated (`.gif`) wallpapers. (optional)

### Patched Waybar
Waybar ≤ 0.15.0 hardcodes `hyprctl dispatch workspace <id>` for workspace clicks, which the Lua
config manager rejects. A patched build is installed at `~/.local/bin/waybar` (ahead of the system
one in `PATH`); its `hyprland/workspaces` module sends
`dispatch hl.dsp.focus({ workspace = "<id>" })` instead. Rebuild after Waybar updates:

```bash
git clone --branch 0.15.0 --depth 1 https://github.com/Alexays/Waybar /tmp/waybar
cd /tmp/waybar
# patch src/modules/hyprland/workspace.cpp to emit the Lua dispatch form above
meson setup build -Dcava=disabled --prefix="$HOME/.local"
ninja -C build install
```
