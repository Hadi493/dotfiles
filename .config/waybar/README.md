# Waybar Configuration

A clean waybar configuration for Hyprland.

### Screenshot
![screenshot](./waybar.png)

## Requirements 

**Core Components:**

*   `waybar`: The status bar itself.
*   `hyprland` or `dwl`: The Wayland compositor this configuration is designed for.

**Launchers & Menus:**

*   `rofi`: Used for various menus like the control center, power menu, and quick actions.
*   `wlogout`: Used as a logout menu.

**Notifications:**

*   `swaync` or `dunst`: For notification management.
*   `notify-send`: For sending notifications from scripts.

**System & Hardware Control:**

*   `nmcli`: To manage network connections (Wi-Fi).
*   `bluetoothctl`: To manage Bluetooth devices.
*   `brightnessctl`: To control screen brightness.
*   `wpctl` (part of `wireplumber`): To control audio volume.
*   `pactl` (part of `pulseaudio`): To control audio volume.
*   `systemctl`: For system-level actions like reboot, shutdown, and suspend.
*   `hyprlock`: For screen locking.

**Terminal Emulators:**

*   `kitty`: Used to launch terminal applications like `htop`, `nmtui`, etc.

**Utilities:**

*   `jq`: For parsing JSON output from `hyprctl`.
*   `playerctl`: For controlling media players.
*   `curl`: For fetching weather information.
*   `fortune`: For displaying a random quote.
*   `checkupdates` (part of `pacman-contrib` on Arch Linux): For checking for package updates.
*   `htop`: For process monitoring.
*   `s-tui`: For stress testing and monitoring.
*   `nmtui`: For network management in the terminal.
*   `gdu`: For disk usage analysis.
*   `pavucontrol`: For audio volume control.
*   `fcitx5-configtool`: For input method configuration.
*   `gnome-control-center`: As a fallback for system settings.
*   `setxkbmap`: As a fallback for keyboard layout switching.
*   `cal`: For displaying a calendar.
*   `pkill`: For process management.

**Fonts:**

*   `Iosevka Nerd Font`: The primary font used in the `style.css`.
*   `JetBrains Mono`: Used in the `control_center.sh` script's rofi theme.

## Installation

1.  **Install all the required packages.**

    For Arch Linux, you can use the following command:

    ```bash
    sudo pacman -S waybar hyprland rofi wlogout swaync networkmanager bluez brightnessctl wireplumber pulseaudio systemd hyprlock kitty jq playerctl curl fortune-mod pacman-contrib htop btop s-tui nmtui gdu pavucontrol fcitx5-configtool setxkbmap util-linux pkill ttf-iosevka-nerd ttf-jetbrains-mono
    ```

2.  **Clone this repository to your `~/.config/` directory:**

    ```bash
    git clone https://github.com/cyber-green/waybar-config.git ~/.config/waybar
    ```

3.  **Make the scripts executable:**

    ```bash
    chmod +x ~/.config/waybar/scripts/*.sh
    ```

## Usage

1.  **Launch Waybar.**

    You can launch Waybar from your terminal:

    ```bash
    waybar
    ```

    Or, you can add it to your compositor configuration to launch it automatically on startup:

    **Hyprland:**
    ```
    exec-once = waybar
    ```

    **dwl:**
    Add it to your `autostart` script or launch it before `dwl`:
    ```bash
    waybar &
    swaync &
    ```

2.  **Enjoy your new Waybar!**

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please see the [CONTRIBUTING.md](CONTRIBUTING.md) file for details.
