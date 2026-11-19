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

## Clicking a notification

A click runs **the sender's default action**, nothing more. From
`notification.vala`:

```vala
private void action_clicked (Action ?action) {
    noti_daemon.run_scripts (param, ScriptRunOnType.ACTION);
    if (action != null && action.identifier != "") { ... ActionInvoked ... }
}
```

The freedesktop spec has no "focus the sender" field, so when a sender ships no
action (plain `notify-send`, many browsers) a click does nothing at all — no
focus, no dismiss. That is why "click the notification to reach the app"
appeared broken.

`run_scripts` fires *before* that null check, so it is the one hook available
without patching swaync:

| Piece | Value |
|---|---|
| `config.json` → `scripts.focus-app-on-click` | `exec: ~/dotfiles/.config/hypr/scripts/notify-focus`, `run-on: action` |
| Script input | `SWAYNC_APP_NAME`, `SWAYNC_DESKTOP_ENTRY` |
| Matching | case-insensitive substring of the window's class / initialClass / title, most recently focused wins |
| Focus call | `hl.dispatch(hl.dsp.focus({ window = w }))` on the window object — the dispatcher rejects a bare address string — with unmapped windows merged in so another workspace can be reached |

Notes:

- The `exec` path must be `~/dotfiles/...`: `~/.config/hypr` is an installed
  loader, not a symlink, so `~/.config/hypr/scripts/` does not exist.
- Only the **first** matching script runs, so this catch-all entry owns the
  `scripts` key; adding another script means merging the two.
- Notifications from `notify-send` are ignored (that is our own volume/mic OSD),
  and an unmatched app name leaves focus untouched.

## OSD presentation

The OSD is swaync's *floating-notification* window, restyled as a top-centre
island. Everything is scoped to `.floating-notifications`, so the control
centre keeps its own styling.

| Aspect | Setting | Where |
|---|---|---|
| Position / size | `positionX: center`, `positionY: top`, `notification-window-width: 360` | `config.json` |
| Icon | `notification-icon-size: 34` | `config.json` |
| Fade | `transition-time: 150` (popup lifetime comes from `notify-send -t 900`) | `config.json` |
| Shape | 24 px radius, 78 % opaque background, soft shadow | `style.css` |
| Frost | `hl.layer_rule({ match = { namespace = "swaync-notification-window" }, blur = true })` | `.config/hypr/conf/theme.lua` |

Two consequences worth knowing:

- **Only `.notification` is a surface.** The popup nests a window container
  (`.floating-notifications.background`, a fixed 360 px wide and taller than the
  pill) around a row wrapper (`.notification-row .notification-background`)
  around `.notification`. Leaving the window or wrapper painted draws a second,
  square-cornered rectangle behind the island — the CSS explicitly clears both
  and adds no `box-shadow`, because the rest of the theme is flat.

- **Blur needs `decoration.blur.enabled = true`**, which the theme now sets. No
  window rule asks for blur, so tiled clients stay sharp; only this layer is
  frosted.
- **There is no level bar in swaync.** `swaync 0.12` has no OSD slider or bar
  option, so `scripts/volume` builds one from eight block glyphs (`▰`/`▱`) in
  the notification body. Iosevka is monospace, so the bar keeps a fixed width.
  The percentage is right-aligned beside it.

Urgency carries the colour, so one CSS rule per state instead of a per-app hack:

| State | Urgency | Accent |
|---|---|---|
| Volume | `normal` | gold (`@yellow`) |
| Mic live | `low` | blue (`@blue`) |
| Volume/mic muted | `critical` | red (`@red`), red border |

`osd-daemon/` (the local Go experiment) is **not** the notification owner: it
implements only `Notify`/`CloseNotification`, so making it the daemon costs the
panel, history and `Super+N`. It is untracked and not installed by `deploy`.

## Gotchas

- If notifications stop appearing, check the unit first:
  `systemctl --user status swaync.service`.
- `notify-send` calls in scripts assume swaync is the daemon; a second daemon
  (dunst, mako) will steal the name and break the OSD.
