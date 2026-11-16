# hosts/

Per-machine notes and hardware facts. Nothing here is linked or executed.

- One directory per hostname (`hostname` at login).
- Machine-specific **config** does not live here: monitor overrides go in the
  untracked `~/.config/hypr/monitors.local.lua`, secrets in `*.local` files.
- This directory records what the machine is, so an agent can tell whether a
  default (panel, GPU, backlight) applies.

| Host | Notes |
|---|---|
| [`cyber-green/`](cyber-green/README.md) | Arch-based (`cg-os`), Hyprland, eDP-1 1920x1080, Intel UHD 630 |
