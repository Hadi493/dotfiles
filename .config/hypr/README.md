# Hadi Alam's Personal hyprland config

This is a modularized Hyprland configuration.

### Requirements:
This configuration depends on a variety of packages to be fully functional. Here is a list of the required software:

#### Core Compositor & Utilities
- **`hyprland`**: The Wayland compositor itself.
- **`hypridle`**: The idle management daemon for Hyprland.
- **`hyprlock`**: The screen locker for Hyprland.
- **`hyprpicker`**: A color picker utility.
- **`hyprshot`**: A screenshot tool for Hyprland.

#### System & Session Management
- **`xdg-desktop-portal-hyprland`**: Backend for xdg-desktop-portal, necessary for screen sharing and other integrations.
- **`pipewire`** & **`wireplumber`**: For audio management (`wpctl`).
- **`systemd`**: Provides `loginctl` and `systemctl` for session and power management.
- **`dbus`**: For inter-process communication.
- **`swayosd`**: On-screen display for volume, brightness, etc. (Covers both client and server).

#### Bars, Launchers & Notifications
- **`waybar`**: A highly customizable Wayland status bar.
- **`rofi`**: A versatile application launcher and menu generator.
- **`tofi`**: Another application launcher.
- **`swaync`**: A Wayland notification center.
- **`wlogout`**: A logout menu.

#### Clipboard Management
- **`wl-clipboard`**: Provides `wl-paste` and `wl-copy` for command-line clipboard access.
- **`cliphist`**: A clipboard history manager.
- **`clipman`**: A clipboard manager.

#### Theming & Visuals
- **`swaybg`**: A wallpaper manager for Wayland.
- **`pywal`**: A tool to generate and apply color palettes from images.
- **`nerd-font`**: A font for icons and symbols to display correctly.

#### Hardware & Media Control
- **`brightnessctl`**: For controlling screen brightness.
- **`playerctl`**: For controlling media players.
- **`gammastep`**: For color temperature adjustment.
- **`wiremix`**: For controlling audio inputs and outputs.

#### Applications
- **`kitty`**: A GPU-accelerated terminal emulator.
- **`emacs`**: A text editor.
- **`nautilus`**: A file manager.
- **`vesktop-wayland`**: A Discord client.
- **`google-chrome-stable`**: Web browser.
- **`brave`**: Web browser.

#### Other Tools
- **`boomer`**: A tool for zoom-in.
- **`cg-timer`**: A timer application. (personal)
- **`walker`**: An application launcher.
- **`elephant`**: A helper for `walker`.
