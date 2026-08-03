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

hl.plugin.load("/var/cache/hyprpm/hadi/hyprland-scroll-overview/scrolloverview.so")

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
