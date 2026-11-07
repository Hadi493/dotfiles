-- Personal lightweight keybinds (no Ryoku, no quickshell).
-- Vanilla backends only: wpctl, brightnessctl, playerctl, rofi, grim/slurp,
-- hyprpicker, hyprlock, wlogout, cliphist+tofi, swaync-client.
-- Scripts live at ~/dotfiles/.config/hypr/scripts (referenced absolute so a
-- Ryoku-managed ~/.config/hypr can never shadow them).

local P = require("conf.variables")
local DOT = os.getenv("HOME") .. "/dotfiles/.config/hypr"

local mainMod = "SUPER"

-- Audio (wpctl / PipeWire). Locked so volume works on the lockscreen.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(DOT .. "/scripts/input-mute-toggle"), { locked = true })

hl.bind("ALT + Q", hl.dsp.exec_cmd(P.quran))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(P.herdr))
hl.bind(mainMod .. "+ SHIFT + Return", hl.dsp.exec_cmd(P.terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(P.audiosettings))
hl.bind("ALT + A", hl.dsp.exec_cmd("kitty --title alsamixer alsamixer")) -- hardware mic/volume levels
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(P.fileManager))
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(P.menu)) -- rofi drun
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(P.discord))
hl.bind("ALT + SHIFT + D", hl.dsp.exec_cmd(P.discord_web))
hl.bind("CTRL + SHIFT + D", hl.dsp.exec_cmd(P.discord_web2))
hl.bind("ALT + T", hl.dsp.exec_cmd(P.telegram))
hl.bind("ALT + R", hl.dsp.exec_cmd(P.reddit))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd(P.tmenu))
hl.bind("ALT + F", hl.dsp.exec_cmd(P.facebook))
hl.bind("ALT + SHIFT + F", hl.dsp.exec_cmd(P.facebook2))
hl.bind(mainMod .. "+ SHIFT + F", hl.dsp.exec_cmd(P.magnific))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(P.whatsapp))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd(P.yt))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(P.twitch))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("brave-origin"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd(DOT .. "/scripts/url_launcher_gui.py"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock -c ~/dotfiles/.config/hypr/hyprlock.conf"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("pavucontrol"))
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("swaync-client --toggle-dnd"))
hl.bind(mainMod .. " + J", hl.dsp.exec_cmd("kitty nmtui"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(P.codeditor))

hl.bind("ALT + C", hl.dsp.exec_cmd("kitty peaclock"))

hl.bind(mainMod .. "+ G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.group.prev())
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.group.next())
-- Lightweight window switchers (no Ryoku MRU strip / expo).
hl.bind("ALT + Tab", hl.dsp.exec_cmd("rofi -show window -config ~/.config/rofi/config.rasi"))
hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd("rofi -show window -config ~/.config/rofi/config.rasi"))

hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("coomer"))

-- Clipboard via dotfiles script (tofi-based).
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(DOT .. "/scripts/clipboard"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(DOT .. "/scripts/clipboard pass"))

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(DOT .. "/scripts/toggle_recording"))
hl.bind(mainMod .. " + t", hl.dsp.exec_cmd("cg-timer"))

hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("systemctl poweroff"))

hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(P.wallpaper_selector))

-- Screenshots: grim + slurp to ~/Pictures/Screenshots, clipboard copy.
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp)\" ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send -t 1500 Screenshot 'Saved to ~/Pictures/Screenshots'"))
hl.bind("PRINT", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp)\" ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send -t 1500 Screenshot 'Saved to ~/Pictures/Screenshots'"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send -t 1500 Screenshot 'Saved to ~/Pictures/Screenshots'"))

hl.bind("CTRL + Escape", hl.dsp.exec_cmd("bash -c 'pgrep -x waybar >/dev/null && pkill waybar || (waybar &)'"))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd(DOT .. "/scripts/toggle_gaps"))
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("wlogout"))

-- Focus navigation (wraps first<->last in scrolling layout)
hl.bind(mainMod .. " + left", hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + right", hl.dsp.layout("focus r"))
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.layout("focus u"))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.layout("focus d"))

-- Scrolling layout keybindings
hl.bind(mainMod .. " + period", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + comma", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.layout("promote"))
hl.bind(mainMod .. " + ALT + period", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + ALT + comma", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + backslash", hl.dsp.layout("fit active"))

hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("hyprctl dispatch cyclewindow"))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.exec_cmd("hyprctl dispatch cyclewindow --prev"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("~/opt/squashfs-root/AppRun")) -- session app

hl.bind("ALT + S", hl.dsp.exec_cmd("~/opt/squashfs-root/AppRun"))

-- Touchpad swipe gestures for workspace switching (niri-like)
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

-- Scroll through columns with mainMod + scroll (niri-like)
hl.bind(mainMod .. " + mouse_down", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + mouse_up", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + SHIFT + mouse_down", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + SHIFT + mouse_up", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + CTRL + mouse_down", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + CTRL + mouse_up", hl.dsp.layout("colresize -conf"))

hl.bind("ALT + SHIFT + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + SHIFT + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind("F1", hl.dsp.exec_cmd(P.default_wall))
hl.bind("F3", hl.dsp.exec_cmd("brightnessctl s 100%"))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("F4", hl.dsp.exec_cmd(P.setup_workspace))

-- External monitor via DDC/CI (ddcutil D-Bus). F5/F6 = brightness, Super+F5/F6 = contrast.
hl.bind("F5", hl.dsp.exec_cmd(DOT .. "/scripts/monitor brightness down"))
hl.bind("F6", hl.dsp.exec_cmd(DOT .. "/scripts/monitor brightness up"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(DOT .. "/scripts/monitor brightness down"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(DOT .. "/scripts/monitor brightness up"), { locked = true, repeating = true })
hl.bind(mainMod .. " + F5", hl.dsp.exec_cmd(DOT .. "/scripts/monitor contrast down"))
hl.bind(mainMod .. " + F6", hl.dsp.exec_cmd(DOT .. "/scripts/monitor contrast up"))
hl.bind(mainMod .. " + SHIFT + F5", hl.dsp.exec_cmd(DOT .. "/scripts/monitor input next"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd(DOT .. "/scripts/night_mode"))
hl.bind("F2", hl.dsp.exec_cmd(DOT .. "/scripts/color_temp warmer"))
hl.bind(mainMod .. " + F2", hl.dsp.exec_cmd(DOT .. "/scripts/color_temp cooler"))

hl.bind("F9", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })
hl.bind("F8", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })
hl.bind("F10", hl.dsp.exec_cmd(DOT .. "/scripts/input-mute-toggle"), { locked = true })
hl.bind("F11", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("grim - | wayland-boomer"))

hl.bind(mainMod .. " + bracketleft", hl.dsp.exec_cmd([[hyprctl dispatch 'hl.dsp.window.set_prop({prop="opacity", value="0.70"})']]))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(DOT .. "/scripts/toggle_opacity"))

hl.bind("ALT + E", hl.dsp.exec_cmd(P.web_game_ev))

-- E-ink paper mode toggle
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(DOT .. "/scripts/eink-toggle"))

-- Rotate active monitor (same as before, vanilla script).
hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd(DOT .. "/scripts/rotate-active-monitor next"), { description = "Rotate monitor 90°" })
hl.bind("SUPER + ALT + SHIFT + R", hl.dsp.exec_cmd(DOT .. "/scripts/rotate-active-monitor reset"), { description = "Reset monitor rotation" })
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd(DOT .. "/scripts/rotate-active-monitor next"), { description = "Rotate monitor 90° (alt)" })
hl.bind("CTRL + ALT + SHIFT + R", hl.dsp.exec_cmd(DOT .. "/scripts/rotate-active-monitor reset"), { description = "Reset monitor rotation (alt)" })
