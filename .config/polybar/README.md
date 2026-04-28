# cg-polybar

A clean and modern polybar configuration.

![Screenshot](./screenshots/void-i3.png)



## Features

- **Workspace indicator:** Shows the current workspace and allows you to switch between them.
- **Window title:** Displays the title of the current active window.
- **Microphone status:** Shows the current microphone volume and mute status.
- **Audio control:** Shows the current volume level and allows you to mute/unmute.
- **System monitoring:** Displays CPU and RAM usage.
- **Battery status:** Shows the current battery level and charging status.
- **Network information:** Displays wireless network information.
- **Date and time:** Shows the current date and time.

## Dependencies

- `polybar`
- `xrandr` (for multi-monitor support)
- `pactl` (for microphone and volume control)
- `MesloLGS Nerd Font Mono` (or any other Nerd Font for the icons)

## Installation

1.  **Clone the Repository**
    
    Open your terminal and clone the repository to your local machine:
    
    ```bash
    git clone https://github.com/Hadi493/cg-polybar.git
    cd cg-polybar
    ```
    
2.  **Copy Configuration Files**
    
    Next, copy the configuration files into Polybar's default directory (`~/.config/polybar/`).
    
    ```bash
    mkdir -p ~/.config/polybar
    cp -r ./* ~/.config/polybar/
    ```
    
3.  **Set Script Permissions**
    
    The launch and microphone scripts require executory permissions to run.
    
    ```bash
    chmod +x ~/.config/polybar/launch_polybar.sh
    chmod +x ~/.config/polybar/mic-input.sh
    ```
    

## Usage

### Manual Launch

To test the Polybar configuration, you can launch it manually from your terminal. This is useful for debugging and ensuring that all modules load correctly.

```bash
~/.config/polybar/launch_polybar.sh
```

### Automatic Start with Window Manager

For Polybar to start automatically when you log in, you need to add the launch script to your window manager's startup configuration file.

**For i3:**

Add the following line to your `~/.config/i3/config` file:

```
exec_always --no-startup-id ~/.config/polybar/launch_polybar.sh
```

**For bspwm:**

Add the following line to your `~/.config/bspwm/bspwmrc` file:

```bash
~/.config/polybar/launch_polybar.sh &
```

After adding the line, ensure that the `bspwmrc` file is executable:

```bash
chmod +x ~/.config/bspwm/bspwmrc
```

## Configuration

- `config.ini`: The main polybar configuration file. You can customize the modules, colors, and fonts here.
- `launch_polybar.sh`: A script to launch the polybar. It includes support for multiple monitors using `xrandr`.
- `mic-input.sh`: A script to get the microphone volume and mute status.
