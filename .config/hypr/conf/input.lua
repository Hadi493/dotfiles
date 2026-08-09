hl.config({
    input = {
        kb_layout   = "us",
        kb_variant  = "",
        kb_model    = "",
        kb_options  = "",
        kb_rules    = "",

        follow_mouse = 1,

        repeat_rate  = 60,
        repeat_delay = 300,

        sensitivity = 1.0,
    },
})

hl.config({
    plugin = {
        scrolloverview = {
            gesture_distance = 300,
            scale = 0.5,
            workspace_gap = 10,
            layout = "vertical",
            wallpaper = 0,
            blur = false,

            input = {
                scroll_event_delay = 200,
                touchpad_scroll_factor = 1,
            },

            shadow = {
                enabled = false,
            },
        },
    },
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = 1.0,
})

hl.device({
    name    = "synps/2-synaptics-touchpad",
    enabled = false,
})
