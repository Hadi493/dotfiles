-- Personal lightweight startup (no Ryoku).
-- Hyprland loads this via: Hyprland --config ~/dotfiles/.config/hypr/hyprland.lua
-- (personal Wayland session: hadi-hyprland.desktop)

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- fcitx5 is optional: only export its env vars (and start the daemon) when it
-- is actually installed. The module name is `fcitx`, not `fcitx5`; exporting
-- it without the daemon breaks GTK/Qt input in terminal-launched apps
-- (same rule as fish/user.fish).
local fcitx = ""
local fcitx_p = io.popen("command -v fcitx5 2>/dev/null")
if fcitx_p then
    fcitx = fcitx_p:read("*l") or ""
    fcitx_p:close()
end
if #fcitx > 0 then
    hl.env("XMODIFIERS", "@im=fcitx")
    hl.env("QT_IM_MODULE", "fcitx")
end

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

local DOT = os.getenv("HOME") .. "/dotfiles/.config/hypr"

hl.on("hyprland.start", function()
    if #fcitx > 0 then hl.exec_cmd("fcitx5 -d") end
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Notification daemon (swaync) is owned by the enabled systemd user
    -- unit (dbus activation). Starting it here too makes the unit fail with
    -- "An instance of SwayNotificationCenter is already running!".

    -- Bar (system waybar v0.16). Detached personal session: plain `waybar`
    -- reads ~/.config/waybar (symlinked to dotfiles). Broken patched build
    -- lives at ~/.local/bin/waybar.broken-20261106 — do not restore it.
    -- The 1s delay lets the Hyprland IPC socket come up before waybar
    -- connects (a plain exec at start races it and waybar exits).
    hl.exec_cmd("sh -c 'sleep 1; exec waybar'")

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
