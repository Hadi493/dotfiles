hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 0,

        resize_on_border = true,

        allow_tearing = false,

        layout = "scrolling",
    },

    decoration = {
        rounding = 0,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        dim_inactive = false,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 4,
            color        = "rgba(0d0d0dee)",
        },

        blur = {
            -- Enabled only so the OSD layer rule below can frost the island.
            -- No window rule asks for blur, so tiled clients stay sharp.
            enabled   = true,
            size      = 4,
            passes    = 2,
            vibrancy  = 0.1696,
        },
    },

    group = {
        groupbar = {
            height         = 4,
            gradients      = false,
            render_titles  = false,
            rounding       = 0,
            col = {
                active   = "rgb(E6B450)",
                inactive = "rgba(282828EE)",
            },
        },
    },

    master = {
        orientation = "left",
        mfact       = 0.5,
        new_on_top  = false,
        new_status  = "slave",
    },

    misc = {
        vrr                        = 0,
        force_default_wallpaper    = 0,
        disable_hyprland_logo      = true,
        disable_splash_rendering   = true,
        focus_on_activate          = true,
    },

    render = {
        direct_scanout = false,
    },

    xwayland = {
        force_zero_scaling = true,
    },

    debug = {
        disable_logs = true,
    },
})

-- The OSD is swaync's floating-notification layer. Two rules, both scoped to
-- that namespace: a frosted backdrop for the island itself (its CSS paints a
-- translucent rounded rectangle, so the blur shows through) and no rounding
-- change elsewhere. Transparent pixels are ignored so only the island blurs.
hl.layer_rule({
    name         = "osd-blur",
    match        = { namespace = "swaync-notification-window" },
    blur         = true,
    ignore_alpha = 0.2,
})
