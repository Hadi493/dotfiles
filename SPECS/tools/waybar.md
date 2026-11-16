# Waybar

## Purpose

Top bar: workspaces, clock, notifications, clipboard, network, audio, mic, CPU,
memory, tray, updates, power.

## Files

| Path | Role |
|---|---|
| `.config/waybar/config.jsonc` | Modules, module options, on-click handlers. |
| `.config/waybar/style.css` | Gruber Darker Ayu theme. |
| `.config/waybar/scripts/` | `mic.sh`, `notification_indicator.sh`, `updates.sh`, `wlogout.sh`. |

## Dependencies

`waybar` (system package 0.16 — **not** a patched build), `jq`, `pactl`,
`swaync-client`, `pacman`, `yay`/`paru` (for the updates module).

## Startup

Launched from `conf/startup.lua` as `sh -c 'sleep 1; exec waybar'`. The 1 s
delay is required: waybar exits if it connects before the Hyprland IPC socket
exists. `Ctrl+Esc` toggles it via `pgrep -x waybar && pkill waybar || (waybar &)`.

## Design decisions

- **Plain `waybar` only.** No `~/.local/bin/waybar` override. A broken patched
  build lives at `~/.local/bin/waybar.broken-20261106`; never restore it.
- **Built-in modules only.** Per-interval helper scripts were removed in favour
  of native modules; the four remaining scripts are event streams or need
  `pactl`/`pacman`.
- **swaync indicator** wraps `swaync-client --subscribe-waybar`, so the bell is
  always visible and the count is hidden at zero.
- **Fuzzel is not used here.** The clipboard button calls
  `~/dotfiles/.config/hypr/scripts/clipboard` (a repo-absolute path, so the
  bar keeps working if `~/.config/waybar` is replaced).

## Gotchas

- `custom/clipboard` and `custom/notification` hardcode `~/dotfiles/...`; they
  are covered by INV-1.
- `updates.sh` shells out to `yay -Qua`; if the AUR helper is missing the module
  reports 0 silently.
- Style changes need `killall -SIGUSR2 waybar` (or `Ctrl+Esc` twice).
