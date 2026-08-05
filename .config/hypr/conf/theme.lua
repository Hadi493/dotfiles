hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 10,

        border_size = 0,

        resize_on_border = true,

        allow_tearing = true,

        layout = "scrolling",
    },

    decoration = {
        rounding = 0,

        active_opacity   = 1.0,
        inactive_opacity = 0.79,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 5,
            color        = "rgba(0d0d0dee)",
        },

        blur = {
            enabled   = false,
            size      = 4,
            passes    = 2,
            vibrancy  = 0.1696,
        },
    },

    group = {
        groupbar = {
            height         = 8,
            gradients      = true,
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
        vrr                        = 2,
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
