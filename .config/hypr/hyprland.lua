-----------------
---- MONITORS ----
-----------------

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080",
    position = "auto",
    scale    = 1,
})

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
