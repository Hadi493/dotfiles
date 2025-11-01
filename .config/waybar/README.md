# Waybar Configuration

A clean waybar configuration for Hyprland.

![screenshot](./screenshot/2025-10-30_16-02-37.png)

## Features

This configuration displays the following modules:

**Left modules:**
- Hyprland Workspaces
- Media Player Controls (`playerctl`)
- Active Window Title

**Center modules:**
- Clock with Calendar

**Right modules:**
- Audio controls (speaker + microphone)
- Brightness control
- System monitoring (CPU, memory, temperature)
- Uptime
- Network status
- Battery status
- System tray

## Dependencies

This configuration relies on several external tools and packages to function correctly. The list below corresponds to the modules **currently active** in the `config.jsonc` file.

### Main Components
- **`waybar`**: The bar itself.
- **`hyprland`**: The compositor (the config is tailored for it).
- **`kitty`**: The terminal used for most `on-click` actions.
- **Nerd Font**: A font with icons is required. The config uses `Iosevka Nerd Font`.

### Active Module Dependencies
- **`playerctl`**: For the media player module.
- **`pavucontrol`**: For the audio control panel on click.
- **`pipewire-pulse`** or **`pulseaudio-utils`**: Provides `pactl` for volume control.
- **`brightnessctl`**: For backlight/brightness control.
- **`htop`**: For monitoring CPU/Memory on click.
- **`s-tui`**: For monitoring temperature on click.
- **`network-manager-applet`**: Provides `nmtui` for network management on click.

## Installation

1.  **Install Dependencies:**
    Install all the packages listed in the **Dependencies** section using your package manager. For Arch Linux:
    ```bash
    sudo pacman -S waybar hyprland kitty playerctl pavucontrol pipewire-pulse brightnessctl htop s-tui network-manager-applet
    ```
    *(Note: You may need to install a Nerd Font like `ttf-iosevka-nerd` from the AUR or manually)*

2.  **Clone the Repository:**
    ```bash
    git clone https://github.com/Hadi493/cg-waybar.git ~/.config/waybar
    ```
    *(If you already have a `~/.config/waybar` directory, back it up first or clone into a different directory and copy the files over.)*

3.  **Reload Waybar:**
    Restart Waybar for the changes to take effect.
    ```bash
    killall waybar && waybar &
    ```

## Usage

### Interactive Controls

**Workspaces:**
- Hover/Click to switch workspaces.

**PlayerCTL (Music):**
- Left click: Play/Pause
- Right click: Stop
- Scroll: Adjust volume

**Clock:**
- Alt-Click: Toggle time/date format
- Calendar popup on hover

**Audio (PulseAudio):**
- Left click: Open `pavucontrol`
- Right click: Mute/unmute speaker
- Scroll: Adjust speaker volume

**Microphone:**
- Left click: Mute/unmute microphone
- Scroll: Adjust microphone volume

**Brightness:**
- Scroll: Adjust screen brightness

**Network:**
- Left click: Open network manager (`nmtui`)

**System Monitoring:**
- Click CPU/Memory: Open `htop`
- Click Temperature: Open `s-tui`

### Customization

The configuration includes several other modules that are not enabled by default (e.g., `custom/weather`, `custom/updates`, `disk`, `custom/language`). You can enable them by adding them to `modules-left`, `modules-center`, or `modules-right` in `config.jsonc`. If you enable them, make sure you have their respective dependencies installed.

Edit `config.jsonc` for module settings and `style.css` for appearance.
