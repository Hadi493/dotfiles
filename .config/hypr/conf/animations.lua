hl.config({ animations = { enabled = true } })

hl.curve("wind",   { type = "bezier", points = { {0.05, 0.9},   {0.1, 1.05} } })
hl.curve("winIn",  { type = "bezier", points = { {0.1, 1.1},    {0.1, 1.1} } })
hl.curve("winOut", { type = "bezier", points = { {0.3, -0.3},   {0, 1} } })
hl.curve("smooth", { type = "bezier", points = { {0.04, 0.93},  {0.12, 1.02} } })

hl.animation({ leaf = "windows",     enabled = true, speed = 5, bezier = "wind",   style = "slide" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5, bezier = "winIn",  style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 3, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "wind" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "fadeDim",     enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 4, bezier = "smooth", style = "slidevert" })
