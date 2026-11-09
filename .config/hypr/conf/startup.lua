-- Personal lightweight startup (no Ryoku).
-- Hyprland loads this via: Hyprland --config ~/dotfiles/.config/hypr/hyprland.lua
-- (personal Wayland session: hadi-hyprland.desktop)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

local DOT = os.getenv("HOME") .. "/dotfiles/.config/hypr"

hl.on("hyprland.start", function()
    hl.exec_cmd("fcitx5 -d")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Notification daemon (swaync). Unmasked for personal session:
    -- `systemctl --user unmask swaync.service`
    hl.exec_cmd("swaync")

    -- Bar (system waybar v0.15). Detached personal session: plain `waybar`
    -- reads ~/.config/waybar (symlinked to dotfiles). Broken patched build
    -- lives at ~/.local/bin/waybar.broken-20261106 — do not restore it.
    hl.exec_cmd("waybar")

    -- Wallpaper via swaybg/mpvpaper lib in dotfiles/scripts (no ryogami).
    hl.exec_cmd(DOT .. "/scripts/restore_wallpaper")

    -- Portals come up via dbus activation; no manual kill/restart needed.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Idle / lock (hypridle + hyprlock).
    hl.exec_cmd(DOT .. "/scripts/run_hypridle")

    -- Break timer (notify-send -> swaync).
    hl.exec_cmd(DOT .. "/scripts/break &")

    -- Colour temperature (hyprsunset, native Hyprland IPC).
    hl.exec_cmd("pgrep -x hyprsunset >/dev/null || hyprsunset")

    -- Login mic fix (USB mic default, unmuted) via pactl.
    hl.exec_cmd(DOT .. "/scripts/unmute_mic.sh")
end)
