-----------------
---- MONITORS ----
-----------------
-- Default for this machine. A per-machine override may live outside the repo
-- at ~/.config/hypr/monitors.local.lua (gitignored): it must call hl.monitor()
-- itself and fully replaces this default. Never add a host override here.
local monitors_override = os.getenv("HOME") .. "/.config/hypr/monitors.local.lua"
local monitors_file = io.open(monitors_override, "r")

if monitors_file then
    monitors_file:close()
    dofile(monitors_override)
else
    hl.monitor({
        output   = "eDP-1",
        mode     = "1920x1080",
        position = "auto",
        scale    = 1,
    })
end

-----------------
---- PLUGINS ----
-----------------
-- (none: scrolloverview/hyprexpo unusable on Hyprland 0.56.2, see git history)

--------------------------
---- SOURCE SECTIONS ----
--------------------------

require("conf.variables")
require("conf.startup")
require("conf.animations")
require("conf.input")
require("conf.theme")
require("conf.window_rules")
require("conf.keybinds")
