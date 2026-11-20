# Hyprland

## Purpose

Wayland compositor for the whole desktop. Runs on a TTY (no display manager)
with the built-in **scrolling** layout (niri-like columns).

## Files

| Path | Role |
|---|---|
| `.config/hypr/hyprland.lua` | Entry point: monitor default, then `require` of every section. |
| `.config/hypr/loader.lua` | Installed as `~/.config/hypr/hyprland.lua` by `./deploy hypr`. |
| `conf/variables.lua` | Program choices (`P.*`): terminal, launcher, browser profiles, scripts. |
| `conf/startup.lua` | Env vars + `hyprland.start` autostart list. |
| `conf/keybinds.lua` | Every bind, through the local `bind()` wrapper. |
| `conf/theme.lua` | Gaps, borders, rounding, opacity, blur/shadow, scrolling layout. |
| `conf/animations.lua` | Intentionally `enabled = false`. |
| `conf/input.lua` | `us` keyboard, touchpad disabled, mouse sensitivity. |
| `conf/window_rules.lua` | Floating/size/position rules per app class. |
| `hypridle.conf`, `hyprlock.conf` | Used by explicit path (separate programs). |
| `scripts/` | Session helpers (wallpaper, volume, clipboard, monitor, …). |

## Dependencies

`hyprland` 0.57.x (Lua config), `hypridle`, `hyprlock`, `hyprsunset`,
`hyprpicker`, `xdg-desktop-portal-hyprland`, `pipewire`/`wireplumber`, `dbus`.

## Keybindings

The full map is in `.config/hypr/README.md`. The only rule that matters when
editing: **all binds go through the local `bind()` helper** (see INV-3).
Because of the same 0.57 migration, IPC dispatches use Lua syntax:

```bash
hyprctl dispatch 'hl.dsp.exec_cmd("notify-send hello")'
```

## Design decisions

- **Lua tree, no `.conf`.** Hyprland 0.57 only loads the Lua tree; the old
  `.conf` files were deleted rather than kept as dead weight.
- **Loader, not symlink.** `require()` resolves relative to the loaded file
  (INV-2).
- **No animations, and blur only for the OSD.** The Intel UHD 630 cannot
  sustain motion/blur for windows, so `decoration.blur.enabled` is on *solely*
  so one layer rule can frost the OSD island (`swaync-notification-window`);
  no window rule requests blur, so tiled clients stay sharp and unblurred. If
  the compositor feels heavy, deleting that single `hl.layer_rule` in
  `conf/theme.lua` restores the old behaviour.
- **Monitor override outside the repo.** `hyprland.lua` checks for
  `~/.config/hypr/monitors.local.lua` and `dofile`s it when present; otherwise
  it applies the `eDP-1 1920x1080` default. Per-machine output changes belong
  there, never in the tracked file.
- **Global Alt+Tab.** `hl.get_windows()` returns only mapped windows and the
  built-in cycle stays inside a workspace, so `cycle_global()` merges
  `mapped=false`, dedupes by address and sorts by `focus_history_id`.

## Gotchas

- `hyprctl reload` re-runs `hyprland.start`: bar and helper daemons respawn.
- `Print` is **flameshot**, not grim/slurp; the old screenshot binds are
  commented out in `conf/keybinds.lua`.
- `F3`/`brightnessctl` has no backlight device on this machine (documented in
  the Hyprland README caveats).
- Brightness is **DDC/CI on the external panel**, not a backlight: `F5`/`F6`
  and the `XF86MonBrightness*` keys call `scripts/monitor brightness up|down`,
  which talks to `ddcutil-service` over D-Bus (`ddcutil --bus 4` is the same
  panel, ~70 ms read / ~170 ms write). The script shows the volume-style island
  OSD and caches the value it wrote for 1.5 s, serialising presses with
  `flock`, because `GetVcp` keeps answering with the old value for a moment
  after `SetVcp` — without that, a held key stays on one step.
- `scripts/monitor` assumes DDC display number `1` and a single external panel.
