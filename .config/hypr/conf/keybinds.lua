-- Personal lightweight keybinds (vanilla tools only).
-- Scripts live at ~/dotfiles/.config/hypr/scripts (referenced absolute so a
-- managed ~/.config/hypr can never shadow them).

local P = require("conf.variables")
local DOT = os.getenv("HOME") .. "/dotfiles/.config/hypr"

local mainMod = "SUPER"

-- Hyprland 0.57 bug: a bind registered with a dispatcher table is silently
-- dead (the key registers in `hyprctl binds` but pressing it does nothing).
-- A raw Lua function dispatches correctly, so wrap every dispatcher.
-- Ref: hyprwm/Hyprland#17425, wiki.hypr.land/configuring/core/binds
local hl_bind = hl.bind
local function bind(keys, disp, opts)
    if type(disp) == "function" then
        return hl_bind(keys, disp, opts)
    end
    return hl_bind(keys, function()
        return hl.dispatch(disp)
    end, opts)
end

-- Global MRU window cycle for Alt+Tab. hl.dsp.window.cycle_next() only
-- cycles inside the active workspace (in the scrolling layout it behaves
-- like movefocus), so with one window per workspace it never leaves the
-- workspace. Build the MRU list from the focus history instead.
-- focus_history_id: 0 = most recently focused, -1 = never focused.
local function cycle_global(prev)
    local wins = hl.get_windows()
    if #wins < 2 then return end
    table.sort(wins, function(a, b)
        local fa, fb = a.focus_history_id, b.focus_history_id
        if fa < 0 then fa = math.huge end
        if fb < 0 then fb = math.huge end
        return fa < fb
    end)
    local active = hl.get_active_window()
    local idx = 1
    if active then
        for i, w in ipairs(wins) do
            if w.address == active.address then
                idx = i
                break
            end
        end
    end
    local target = prev and (idx > 1 and idx - 1 or #wins)
        or (idx < #wins and idx + 1 or 1)
    hl.dispatch(hl.dsp.focus({ window = wins[target].address }))
end

-- Audio (wpctl / PipeWire). Locked so volume works on the lockscreen.
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(DOT .. "/scripts/volume up"), { locked = true })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(DOT .. "/scripts/volume down"), { locked = true })
bind("XF86AudioMute", hl.dsp.exec_cmd(DOT .. "/scripts/volume mute"), { locked = true })
bind("XF86AudioMicMute", hl.dsp.exec_cmd(DOT .. "/scripts/input-mute-toggle"), { locked = true })

bind("ALT + Q", hl.dsp.exec_cmd(P.quran))
bind(mainMod .. " + Return", hl.dsp.exec_cmd(P.herdr))
bind(mainMod .. "+ SHIFT + Return", hl.dsp.exec_cmd(P.terminal))
bind(mainMod .. " + Q", hl.dsp.window.close())
bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
bind(mainMod .. " + A", hl.dsp.exec_cmd(P.audiosettings))
bind("ALT + A", hl.dsp.exec_cmd("kitty --title alsamixer alsamixer")) -- hardware mic/volume levels
bind(mainMod .. " + E", hl.dsp.exec_cmd(P.fileManager))
bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
bind(mainMod .. " + D", hl.dsp.exec_cmd(P.menu)) -- rofi drun
bind(mainMod .. " + SHIFT + D", hl.dsp.exec_cmd(P.discord))
bind("ALT + SHIFT + D", hl.dsp.exec_cmd(P.discord_web))
bind("CTRL + SHIFT + D", hl.dsp.exec_cmd(P.discord_web2))
bind("ALT + T", hl.dsp.exec_cmd(P.telegram))
bind("ALT + R", hl.dsp.exec_cmd(P.reddit))
bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd(P.tmenu))
bind("ALT + F", hl.dsp.exec_cmd(P.facebook))
bind("ALT + SHIFT + F", hl.dsp.exec_cmd(P.facebook2))
bind(mainMod .. "+ SHIFT + F", hl.dsp.exec_cmd(P.magnific))
bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(P.whatsapp))
bind(mainMod .. " + Y", hl.dsp.exec_cmd(P.yt))
bind(mainMod .. " + T", hl.dsp.exec_cmd(P.twitch))
bind(mainMod .. " + B", hl.dsp.exec_cmd("brave-origin"))
bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprpicker -a"))
bind(mainMod .. " + U", hl.dsp.exec_cmd(DOT .. "/scripts/url_launcher_gui.py"))
bind(mainMod .. " + F", hl.dsp.window.fullscreen())

bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock -c ~/dotfiles/.config/hypr/hyprlock.conf"))
bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client --toggle-panel"))
bind(mainMod .. " + I", hl.dsp.exec_cmd("swaync-client --toggle-dnd"))
bind(mainMod .. " + J", hl.dsp.exec_cmd("kitty nmtui"))
bind(mainMod .. " + C", hl.dsp.exec_cmd(P.codeditor))

bind("ALT + C", hl.dsp.exec_cmd("kitty peaclock"))

bind(mainMod .. "+ G", hl.dsp.group.toggle())
bind(mainMod .. " + ALT + left", hl.dsp.group.prev())
bind(mainMod .. " + ALT + right", hl.dsp.group.next())
bind("ALT + Tab", function() cycle_global(false) end)
bind("ALT + SHIFT + Tab", function() cycle_global(true) end)

-- Clipboard via dotfiles script (fuzzel-based, image thumbnails).
bind(mainMod .. " + V", hl.dsp.exec_cmd(DOT .. "/scripts/clipboard"))
bind(mainMod .. " + ALT + V", hl.dsp.exec_cmd(DOT .. "/scripts/clipboard manage"))
bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd(DOT .. "/scripts/clipboard pass"))

bind(mainMod .. " + R", hl.dsp.exec_cmd(DOT .. "/scripts/toggle_recording"))
bind(mainMod .. " + t", hl.dsp.exec_cmd("cg-timer"))

bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("systemctl poweroff"))

bind(mainMod .. " + M", hl.dsp.exec_cmd(DOT .. "/scripts/volume mute"), { locked = true })

bind(mainMod .. " + W", hl.dsp.exec_cmd(P.wallpaper_selector))

-- Screenshots: grim + slurp to ~/Pictures/Screenshots, clipboard copy.
bind(mainMod .. " + PRINT", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp)\" ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send -t 1500 Screenshot 'Saved to ~/Pictures/Screenshots'"))
bind("PRINT", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp)\" ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send -t 1500 Screenshot 'Saved to ~/Pictures/Screenshots'"))
bind("SHIFT + PRINT", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send -t 1500 Screenshot 'Saved to ~/Pictures/Screenshots'"))

bind("CTRL + Escape", hl.dsp.exec_cmd("bash -c 'pgrep -x waybar >/dev/null && pkill waybar || (waybar &)'"))
bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd(DOT .. "/scripts/toggle_gaps"))
bind("SUPER + ESCAPE", hl.dsp.exec_cmd("wlogout"))

-- Focus navigation (wraps first<->last in scrolling layout)
bind(mainMod .. " + left", hl.dsp.layout("focus l"))
bind(mainMod .. " + right", hl.dsp.layout("focus r"))
bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
bind(mainMod .. " + SHIFT + up", hl.dsp.layout("focus u"))
bind(mainMod .. " + SHIFT + down", hl.dsp.layout("focus d"))

-- Scrolling layout keybindings
bind(mainMod .. " + period", hl.dsp.layout("consume_or_expel next"))
bind(mainMod .. " + comma", hl.dsp.layout("consume_or_expel prev"))
bind(mainMod .. " + SHIFT + period", hl.dsp.layout("swapcol r"))
bind(mainMod .. " + SHIFT + comma", hl.dsp.layout("swapcol l"))
bind(mainMod .. " + SHIFT + bracketright", hl.dsp.layout("promote"))
bind(mainMod .. " + ALT + period", hl.dsp.layout("colresize +conf"))
bind(mainMod .. " + ALT + comma", hl.dsp.layout("colresize -conf"))
bind(mainMod .. " + backslash", hl.dsp.layout("fit active"))

bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))

for i = 1, 10 do
    local key = i % 10
    bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

bind(mainMod .. " + down", hl.dsp.focus({ workspace = "e+1" }))
bind(mainMod .. " + up", hl.dsp.focus({ workspace = "e-1" }))
bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())
bind(mainMod .. " + SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }))
bind(mainMod .. " + S", hl.dsp.exec_cmd("~/opt/squashfs-root/AppRun")) -- session app

bind("ALT + S", hl.dsp.exec_cmd("~/opt/squashfs-root/AppRun"))

-- Touchpad swipe gestures for workspace switching (niri-like)
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

-- Scroll through columns with mainMod + scroll (niri-like)
bind(mainMod .. " + mouse_down", hl.dsp.layout("move +col"))
bind(mainMod .. " + mouse_up", hl.dsp.layout("move -col"))
bind(mainMod .. " + SHIFT + mouse_down", hl.dsp.layout("swapcol r"))
bind(mainMod .. " + SHIFT + mouse_up", hl.dsp.layout("swapcol l"))
bind(mainMod .. " + CTRL + mouse_down", hl.dsp.layout("colresize +conf"))
bind(mainMod .. " + CTRL + mouse_up", hl.dsp.layout("colresize -conf"))

bind("ALT + SHIFT + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("ALT + SHIFT + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

bind("F1", hl.dsp.exec_cmd(P.default_wall))
bind("F3", hl.dsp.exec_cmd("brightnessctl s 100%"))

bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

bind("F4", hl.dsp.exec_cmd(P.setup_workspace))

-- External monitor via DDC/CI (ddcutil D-Bus). F5/F6 = brightness, Super+F5/F6 = contrast.
bind("F5", hl.dsp.exec_cmd(DOT .. "/scripts/monitor brightness down"))
bind("F6", hl.dsp.exec_cmd(DOT .. "/scripts/monitor brightness up"))
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(DOT .. "/scripts/monitor brightness down"), { locked = true, repeating = true })
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(DOT .. "/scripts/monitor brightness up"), { locked = true, repeating = true })
bind(mainMod .. " + F5", hl.dsp.exec_cmd(DOT .. "/scripts/monitor contrast down"))
bind(mainMod .. " + F6", hl.dsp.exec_cmd(DOT .. "/scripts/monitor contrast up"))
bind(mainMod .. " + SHIFT + F5", hl.dsp.exec_cmd(DOT .. "/scripts/monitor input next"))
bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd(DOT .. "/scripts/night_mode"))
bind("F2", hl.dsp.exec_cmd(DOT .. "/scripts/color_temp warmer"))
bind(mainMod .. " + F2", hl.dsp.exec_cmd(DOT .. "/scripts/color_temp cooler"))

bind("F9", hl.dsp.exec_cmd(DOT .. "/scripts/volume up"), { locked = true })
bind("F8", hl.dsp.exec_cmd(DOT .. "/scripts/volume down"), { locked = true })
bind("F10", hl.dsp.exec_cmd(DOT .. "/scripts/input-mute-toggle"), { locked = true })
bind("F11", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

bind(mainMod .. " + Z", hl.dsp.exec_cmd("grim - | wayland-boomer"))

bind(mainMod .. " + bracketleft", hl.dsp.exec_cmd([[hyprctl dispatch 'hl.dsp.window.set_prop({prop="opacity", value="0.70"})']]))
bind(mainMod .. " + O", hl.dsp.exec_cmd(DOT .. "/scripts/toggle_opacity"))

bind("ALT + E", hl.dsp.exec_cmd(P.web_game_ev))

-- E-ink paper mode toggle
bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(DOT .. "/scripts/eink-toggle"))

-- Rotate active monitor (same as before, vanilla script).
bind("SUPER + ALT + R", hl.dsp.exec_cmd(DOT .. "/scripts/rotate-active-monitor next"), { description = "Rotate monitor 90°" })
bind("SUPER + ALT + SHIFT + R", hl.dsp.exec_cmd(DOT .. "/scripts/rotate-active-monitor reset"), { description = "Reset monitor rotation" })
bind("CTRL + ALT + R", hl.dsp.exec_cmd(DOT .. "/scripts/rotate-active-monitor next"), { description = "Rotate monitor 90° (alt)" })
bind("CTRL + ALT + SHIFT + R", hl.dsp.exec_cmd(DOT .. "/scripts/rotate-active-monitor reset"), { description = "Reset monitor rotation (alt)" })
