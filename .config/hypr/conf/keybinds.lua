local P = require("conf.variables")

local mainMod = "SUPER"

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(P.terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(P.audiosettings))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(P.fileManager))
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(P.menu))
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(P.discord))
hl.bind("ALT + SHIFT + D", hl.dsp.exec_cmd(P.discord_web))
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
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd(P.colorPicker .. " | wl-copy"))
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("~/.config/hypr/scripts/url_launcher_gui.py"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())

hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("~/.config/waybar/scripts/notification_center.sh"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(P.codeditor))

hl.bind("ALT + C", hl.dsp.exec_cmd("kitty peaclock"))

hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + left", hl.dsp.group.prev())
hl.bind(mainMod .. " + right", hl.dsp.group.next())
hl.bind("ALT + Tab", hl.dsp.group.prev())

hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("coomer"))

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/clipboard clip"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("~/.config/hypr/scripts/clipboard pass"))

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_recording"))
hl.bind(mainMod .. " + t", hl.dsp.exec_cmd("cg-timer"))

hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd([[hyprctl reload ; ~/.config/hypr/scripts/hotcorner &]]))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("systemctl poweroff"))

hl.bind("ALT + R", hl.dsp.exec_cmd([[hyprctl eval 'hl.config({ decoration = { rounding = 20 } })']]))

hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"))

hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(P.wallpaper_selector))

hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd([[hyprshot -m window -o ~/Pictures/screenshots -f $(date +%Y-%m-%d_%H-%M-%S).png]]))
hl.bind("PRINT", hl.dsp.exec_cmd("flameshot gui"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd([[hyprshot -m region -o ~/Pictures/screenshots -f $(date +%Y-%m-%d_%H-%M-%S).png]]))

hl.bind("CTRL + Escape", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_waybar"))
hl.bind("SUPER + ESCAPE", hl.dsp.exec_cmd("wlogout"))

-- Focus navigation (wraps first<->last in scrolling layout)
hl.bind(mainMod .. " + left", hl.dsp.layout("focus l"))
hl.bind(mainMod .. " + right", hl.dsp.layout("focus r"))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

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
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "e-1" }))

hl.bind("ALT + S", hl.dsp.exec_cmd("~/opt/squashfs-root/AppRun"))

hl.bind(mainMod .. " + S", hl.plugin.scrolloverview.overview("toggle"))
hl.bind(mainMod .. " + i", hl.plugin.scrolloverview.navigate("up"))
hl.bind(mainMod .. " + k", hl.plugin.scrolloverview.navigate("down"))
hl.bind(mainMod .. " + h", hl.plugin.scrolloverview.navigate("left"))
hl.bind(mainMod .. " + l", hl.plugin.scrolloverview.navigate("right"))
hl.bind(mainMod .. " + Return", hl.plugin.scrolloverview.overview("select"))

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

hl.bind("ALT + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("ALT + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind("F1", hl.dsp.exec_cmd(P.default_wall))
hl.bind("F3", hl.dsp.exec_cmd("brightnessctl set 100%+"))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("F4", hl.dsp.exec_cmd(P.setup_workspace))

hl.bind("F5", hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness down"))
hl.bind("F6", hl.dsp.exec_cmd("~/.config/hypr/scripts/brightness up"))

hl.bind("F9", hl.dsp.exec_cmd("swayosd-client --output-volume 2"))
hl.bind("F8", hl.dsp.exec_cmd("swayosd-client --output-volume lower --device alsa_output.pci-0000_11_00.4.pro_audio.monitor"))
hl.bind("F10", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/input-mute-toggle"))

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("grim - | wayland-boomer"))

hl.bind(mainMod .. " + bracketleft", hl.dsp.exec_cmd([[hyprctl dispatch 'hl.dsp.window.set_prop({prop="opacity", value="0.70"})']]))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/toggle_opacity"))

hl.bind("ALT + E", hl.dsp.exec_cmd(P.web_game_ev))
