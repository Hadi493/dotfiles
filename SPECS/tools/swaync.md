# swaync

## Purpose

The only notification daemon and the volume/mic OSD. It owns
`org.freedesktop.Notifications`.

## Files

| Path | Role |
|---|---|
| `.config/swaync/config.json` | Position, control-centre size, timeouts, widgets. |
| `.config/swaync/style.css` | Theme. |
| `.config/swaync/swaync.png` | README asset. |

## Dependencies

`swaync`, `libnotify` (`notify-send`), `playerctl` (media widget).

## Lifecycle

- Enabled as a **systemd user unit**, not started from `startup.lua`:
  `systemctl --user enable --now swaync.service` (done by `./deploy swaync`).
- Starting it from Hyprland's startup as well makes the unit fail with
  "An instance of SwayNotificationCenter is already running!".
- `./deploy noswaync` masks it (legacy Noctalia-only path; do not use).

## Interface

| Action | Bind / command |
|---|---|
| Toggle panel | `Super+N` → `swaync-client --toggle-panel` |
| Toggle DND | `Super+I` → `swaync-client --toggle-dnd` |
| Volume/mic OSD | `scripts/volume`, `scripts/input-mute-toggle` notify with a replace-in-place hint (`x-canonical-private-synchronous`), so repeated presses update one popup |

## Design decisions

- **swaync, not swayosd.** Legacy: Noctalia used to own notifications and
  swayosd did the OSD. The personal session replaced both with swaync.
  `.config/swayosd` moved to `legacy/swayosd` and is not linked by `deploy all`.
- **Replace-in-place hint.** Colour-temperature changes notify *without* the
  hint, because they are not repetitive.

## Gotchas

- If notifications stop appearing, check the unit first:
  `systemctl --user status swaync.service`.
- `notify-send` calls in scripts assume swaync is the daemon; a second daemon
  (dunst, mako) will steal the name and break the OSD.
