# Hadi Alam's Personal Hyprland config (lightweight, no Ryoku)

> **Personal session (live since Nov 2026):** Log in via SDDM as **Hadi
> Hyprland (Personal, No Ryoku)** (`~/.local/share/wayland-sessions/hadi-hyprland.desktop`,
> copy at `~/dotfiles/.local/share/wayland-sessions/`). It launches
> `Hyprland --config ~/dotfiles/.config/hypr/hyprland.lua` directly, with
> **no** `start-hyprland` / Ryoku wrapper, **no** quickshell, **no**
> ryogami/matugen, and **no** Ryoku updates touching this tree.
> Ryoku's `~/.config/hypr` is left untouched as a fallback — picking the
> stock **Hyprland** entry at SDDM returns to Ryoku.
>
> Bar: system `waybar` 0.15 (broken patched `~/.local/bin/waybar`
> renamed to `waybar.broken-20261106`), launcher: `rofi`, notifications:
> `swaync`, lock/idle: `hyprlock`/`hypridle`, screenshots: `grim`+`slurp`.
> Verify after edits: `Hyprland --verify-config --config ~/dotfiles/.config/hypr/hyprland.lua`
>
> **Notifications are session-specific:** `swaync` owns
> `org.freedesktop.Notifications` in this personal session. The stock
> **Hyprland** (Ryoku) session owns them via SHIMA's `qs` shell instead.
> Both daemons are `systemctl --user` units — only one can own the bus
> name per login. `deploy swaync` enables it; `deploy noswaync` masks it.
> Never run both in the same login.
>
> **Deploy:** `~/dotfiles/deploy -y all` re-applies: `./deploy hypr`
> (installs the SDDM entry above, never symlinks `~/.config/hypr`),
> `./deploy waybar swaync` (bar + notifications + enables swaync),
> plus fish/kitty/rofi/tofi/wlogout etc. `~/.local/bin/waybar` patch
> is gone — use the system package.
>
> **File layout:** `hyprland.lua` requires `conf/{variables,startup,animations,input,theme,window_rules,keybinds}.lua`.
> Idle/lock configs are used with explicit paths:
> `hypridle -c ~/dotfiles/.config/hypr/hypridle.conf`,
> `hyprlock -c ~/dotfiles/.config/hypr/hyprlock.conf` — so Ryoku's
> `~/.config/hypr/` can never shadow them. `Hyprland 0.57.1` required.

## Legacy note: old Ryoku + Shima bindings

The old Ryoku session used `~/.config/hypr/modules/binds.lua` + SHIMA
quickshell OSD. Those `qs -c shell ipc …`, `ryoku:` globals, and
`ryoku-cmd-*` bindings have been replaced in the personal config with
vanilla `wpctl`, `brightnessctl`, `playerctl`, `rofi`, `grim`+`slurp`,
`hyprpicker`, `hyprlock`, `wlogout`, and `swaync-client` — see the intro
block above and `conf/keybinds.lua`.

This is a modularized Hyprland configuration written in **Lua** (`hyprland.lua` + `conf/*.lua`).

> **Note:** Since Hyprland 0.57 the legacy `.conf` format is unsupported (0.56.1 warns about it).
> This config requires Hyprland ≥ 0.56.1 and loads entirely from Lua.

### Requirements:
This configuration depends on a variety of packages to be fully functional. Here is a list of the required software:

#### Core Compositor & Utilities
- **`hyprland`** (≥ 0.56.1): The Wayland compositor itself.
- **Ryoku window switcher** (`ALT+Tab`): MRU strip of the open windows. Backed by
  Ryoku's shell; see "Alt+Tab window switcher" above.
- **Ryoku workspace overview** (`SUPER+Tab` / `SUPER+ALT+Tab`): grid of all open windows and workspaces. (scrolloverview/hyprexpo plugins currently unusable on Hyprland 0.56.2 — recipes kept in git history.)
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
