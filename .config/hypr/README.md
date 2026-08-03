# Hadi Alam's Personal hyprland config

This is a modularized Hyprland configuration written in **Lua** (`hyprland.lua` + `conf/*.lua`).

> **Note:** Since Hyprland 0.57 the legacy `.conf` format is unsupported (0.56.1 warns about it).
> This config requires Hyprland ≥ 0.56.1 and loads entirely from Lua.

### Requirements:
This configuration depends on a variety of packages to be fully functional. Here is a list of the required software:

#### Core Compositor & Utilities
- **`hyprland`** (≥ 0.56.1): The Wayland compositor itself.
- **`hyprland-plugins`**: Provides the `scrolloverview` plugin (Lua-loaded in `hyprland.lua`) used for the overview.
- **`hypridle`**: The idle management daemon for Hyprland.
- **`hyprlock`**: The screen locker for Hyprland.
- **`hyprpicker`**: A color picker utility.
- **`hyprshot`**: A screenshot tool for Hyprland.
- **`grim`**: Used by the "zoom into clipboard" bind.

#### System & Session Management
- **`xdg-desktop-portal-hyprland`**: Backend for xdg-desktop-portal, necessary for screen sharing and other integrations.
- **`pipewire`** & **`wireplumber`**: For audio management (`wpctl`).
- **`systemd`**: Provides `loginctl` and `systemctl` for session and power management.
- **`dbus`**: For inter-process communication.
- **`swayosd`**: On-screen display for volume, brightness, etc. (Covers both client and server).
- **`fcitx5`**: Input method framework (configured via `QT_IM_MODULE`/`XMODIFIERS`).

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
