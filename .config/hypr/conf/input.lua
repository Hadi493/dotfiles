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

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = 1.0,
})

hl.device({
    name    = "synps/2-synaptics-touchpad",
    enabled = false,
})
