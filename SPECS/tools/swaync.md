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
| Brightness / contrast OSD | `F5`/`F6`, `XF86MonBrightness*` → `scripts/monitor brightness up\|down`; `Super+F5`/`Super+F6` → `scripts/monitor contrast up\|down` (DDC/CI on the external panel). Both notify with the tag `monitor`, so the two replace each other |
| Input OSD | `Super+Shift+F5` → `scripts/monitor input next` (cycles inputs from the monitor's capability list; `monitor input list`, `set <value>`) |

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
| Script input | `SWAYNC_APP_NAME`, `SWAYNC_DESKTOP_ENTRY`, `SWAYNC_SUMMARY` |
| Matching | scored, see below |
| Focus call | `hl.dispatch(hl.dsp.focus({ window = w }))` on the window object — the dispatcher rejects a bare address string — with unmapped windows merged in so another workspace can be reached |
| Diagnostic | `~/.cache/notify-focus.log`, last 200 lines: one `focus`/`no-match` line and one `dispatch` line per click |

### Matching

Every candidate string is normalised first: lowercased with `.`, `_` and spaces
folded to `-`, so `Telegram Desktop` and `org.telegram.desktop` compare equal.
Each needle is then scored against a window, highest wins; ties go to the lowest
`focusHistoryID` (most recently focused), and a title containing the
notification summary adds 10.

| Evidence | Weight | Weaker matches |
|---|---|---|
| alias file entry | 110 | — |
| `StartupWMClass` of the desktop entry | 95 | initialClass −5 |
| raw desktop entry | 90 | class prefix −20, class substring −38, title −62 |
| last dot-part of the entry (`org.gnome.Nautilus` → `Nautilus`) | 85 | as above |
| notification app-name | 88 | as above |
| app-name with spaces → dashes (`Telegram Desktop`) | 86 | as above |
| `Exec` basename of the desktop entry | 70 | as above |

The weights are ordered so an exact class match always beats a substring guess.
A bare app-name with two windows of that app (two Brave profiles) is still a
coin flip decided by recency — the desktop entry is what disambiguates, which is
why it outranks the app-name.

Senders whose name has nothing to do with their window class can be mapped in
`~/.config/hypr/notify-focus.aliases` (untracked, like `monitors.local.lua`):

```conf
# notification-app=window-class
herdr=kitty
```

Notes:

- The `exec` path must be `~/dotfiles/...`: `~/.config/hypr` is an installed
  loader, not a symlink, so `~/.config/hypr/scripts/` does not exist.
- Only the **first** matching script runs, so this catch-all entry owns the
  `scripts` key; adding another script means merging the two.
- Notifications from `notify-send` are ignored (that is our own volume/mic OSD),
  and an unmatched app name leaves focus untouched.
- `LatestInvokeAction` on the control-centre bus **cannot** replay a body click:
  it calls `click_alt_action`, which returns early unless the notification has
  alt-action buttons. A real click goes through `click_default_action` →
  `action_clicked(param.default_action)`. Verify the hook by clicking, then
  reading the log.

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
  option, so `scripts/volume` and `scripts/monitor` build one from eight block
  glyphs (`▰`/`▱`) in the notification body. Iosevka is monospace, so the bar
  keeps a fixed width. The percentage is right-aligned beside it. Both use the
  same cells, so the volume and brightness islands look like one family.

Urgency carries the colour, so one CSS rule per state instead of a per-app hack:

| State | Urgency | Accent |
|---|---|---|
| Volume | `normal` | gold (`@yellow`) |
| Mic live | `low` | blue (`@blue`) |
| Volume/mic muted | `critical` | red (`@red`), red border |
| Brightness | `normal` | gold (`@yellow`) |
| Brightness 0 % | `critical` | red (`@red`), red border |

Icons come from **oxygen**, the theme actually in use: it has no
`display-brightness-*` set, so a `-symbolic` Papirus name renders as nothing at
all. Brightness uses its single sun (`weather-clear`, so the bar carries the
level and only the accent changes at 0 %), contrast uses `contrast`, and both
share the tag `monitor` so switching between them updates one card instead of
stacking two.

`osd-daemon/` (the local Go experiment) is **not** the notification owner: it
implements only `Notify`/`CloseNotification`, so making it the daemon costs the
panel, history and `Super+N`. It is untracked and not installed by `deploy`.

## Gotchas

- If notifications stop appearing, check the unit first:
  `systemctl --user status swaync.service`.
- `notify-send` calls in scripts assume swaync is the daemon; a second daemon
  (dunst, mako) will steal the name and break the OSD.
