hl.window_rule({
    name  = "st",
    match = { class = "st-256color" },
    float = true,
    center = true,
    size  = { 1300, 900 },
})

hl.window_rule({
    name  = "move-peaclock",
    match = { class = "peaclock" },
    move  = { 100, 100 },
    float = true,
    size  = { 100, 200 },
})

hl.window_rule({
    name  = "move-emacs",
    match = { class = "Emacs" },
    opacity = "0.88",
})

hl.window_rule({
    name  = "Nautilus",
    match = { class = "org.gnome.Nautilus" },
    float = true,
    size  = { 1500, 900 },
})

hl.window_rule({
    name  = "Eye of Mate",
    match = { class = "eom" },
    float = true,
    size  = { 1400, 900 },
})

hl.window_rule({
    name  = "move-xdg-desktop-portal-gtk",
    match = { class = "xdg-desktop-portal-gtk" },
    float = true,
    size  = { 1020, 700 },
})

hl.window_rule({
    name  = "move-org.pulseaudio.pavucontrol",
    match = { class = "org.pulseaudio.pavucontrol" },
    float = true,
    size  = { 1020, 700 },
})

hl.window_rule({
    name  = "move-cg-timer",
    match = { class = "cg-timer" },
    move  = { 900, 10 },
    float = true,
    size  = { 1000, 250 },
})

hl.window_rule({
    name  = "move-org.gnome.Loupe",
    match = { class = "org.gnome.Loupe" },
    float = true,
    size  = { 1090, 850 },
})

hl.window_rule({
    name  = "waypaper",
    match = { class = "waypaper" },
    float = true,
    size  = { 1090, 850 },
})

hl.window_rule({
    name  = "coomer",
    match = { title = "coomer" },
    float = true,
})

hl.window_rule({
    name  = "url-launcher",
    match = { title = "Brave URL Launcher" },
    float = true,
    center = true,
    size  = { 560, 620 },
})

hl.window_rule({
    name  = "noctalia-settings",
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    center = true,
    size  = { 1080, 920 },
})
