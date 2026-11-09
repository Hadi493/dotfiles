# Personal Hyprland session (lightweight, no Ryoku)

The live desktop is a plain Hyprland session loaded from this repository.
There is no Ryoku, no Quickshell shell, no `ryogami`/matugen integration and no
display manager. `~/dotfiles` is the only config source.

## Boot and deploy

Log in on a TTY and start the compositor:

```bash
start-hyprland      # Hyprland's watchdog launcher (recommended)
# or
Hyprland
```

Both read `~/.config/hypr/hyprland.lua`. That path is **a loader installed by
`./deploy hypr`**, not a symlink to this repo:

```text
TTY login
  └─ start-hyprland / Hyprland
       └─ ~/.config/hypr/hyprland.lua        (installed loader)
            └─ ~/dotfiles/.config/hypr/hyprland.lua
                 └─ require("conf.*")
```

The loader sets `package.path` to `~/dotfiles/.config/hypr` and `dofile`s the
real entry point, because Hyprland resolves `require()` relative to the file it
was given. Never symlink the whole `~/.config/hypr` directory.

```bash
# Apply the loader + optional session entry
./deploy hypr

# Bar + notification daemon (one command each)
./deploy waybar
./deploy swaync

# Everything else
./deploy -y all

# Verify exactly what Hyprland will load
Hyprland --verify-config --config ~/.config/hypr/hyprland.lua
# -> config ok

# Reload a running session
hyprctl reload
```

`~/.local/share/wayland-sessions/hadi-hyprland.desktop` is installed for the
day a display manager is used again. No display manager is enabled today; SDDM
must not be required.

> `hyprctl reload` re-runs the `hyprland.start` handlers, so the bar and helper
> daemons may respawn. `./deploy swaync` enables the `swaync.service` user unit;
> `waybar` is launched by `startup.lua` as an ordinary process.

## File layout

| Path | Purpose |
|---|---|
| `hyprland.lua` | Entry point: monitor, then `require` of every `conf/*.lua` section. |
| `loader.lua` | Template installed as `~/.config/hypr/hyprland.lua` by `./deploy hypr`. |
| `conf/variables.lua` | Program/command choices (`P.*`). |
| `conf/startup.lua` | Environment and `hyprland.start` autostart. |
| `conf/animations.lua` | Animations disabled for the UHD 630. |
| `conf/input.lua` | Keyboard, touchpad, gestures. |
| `conf/theme.lua` | Gaps, borders, rounding, opacity, shadow/blur, scrolling layout. |
| `conf/window_rules.lua` | Floating/centering rules. |
| `conf/keybinds.lua` | All binds, wrapped through the local `bind()` helper. |
| `hypridle.conf` | Used with an explicit path by `scripts/run_hypridle`. |
| `hyprlock.conf` | Used with an explicit path by `Super + L`. |
| `scripts/` | Session helpers (wallpaper, volume, monitor, recording, …). |
| `sounds-*.wav` | Mic mute/unmute feedback used by `input-mute-toggle`. |

The legacy Hyprland `.conf` files (`hyprland.conf`, `keybinds.conf`,
`startup.conf`, …) are **not loaded** by Hyprland 0.57. They may still mention
removed tools; only the Lua tree is authoritative for the compositor.
`hypridle.conf` and `hyprlock.conf` are separate programs and are used with
explicit paths.

## Hyprland 0.57 bind workaround

Hyprland 0.57 registers dispatcher-table binds but never runs them
([hyprwm/Hyprland#17425](https://github.com/hyprwm/Hyprland/issues/17425): the
key appears in `hyprctl binds` and does nothing). `conf/keybinds.lua` therefore
wraps each dispatcher in a raw Lua function:

```lua
local hl_bind = hl.bind
local function bind(keys, disp, opts)
    if type(disp) == "function" then
        return hl_bind(keys, disp, opts)
    end
    return hl_bind(keys, function()
        return hl.dispatch(disp)
    end, opts)
end
```

Keep all new binds on this helper. A raw `hl.bind(..., hl.dsp.window.close())`
will look correct in `hyprctl binds` and stay dead.

Because of the same migration, IPC dispatches use Lua syntax:

```bash
hyprctl dispatch 'hl.dsp.exec_cmd("notify-send hello")'
```

## Session behaviour

`conf/startup.lua` runs on `hyprland.start`:

- `fcitx5 -d` (input method).
- `wl-paste` watchers feeding `cliphist`.
- **swaync** — the only notification daemon; it owns
  `org.freedesktop.Notifications`.
- **waybar** — system package 0.16; no patched build and no `~/.local/bin`
  override.
- `scripts/restore_wallpaper` — `swaybg`/`mpvpaper`.
- `dbus-update-activation-environment` for portals.
- `scripts/run_hypridle` — `hypridle -c ~/dotfiles/.config/hypr/hypridle.conf`.
- `scripts/break` — eye-break reminders via `notify-send`.
- **hyprsunset** — colour temperature (native Hyprland IPC).
- `scripts/unmute_mic.sh` — selects and unmutes the USB mic.

Volume and mic changes send a `swaync` notification with a canonical
replace-in-place hint, so repeated key presses update one OSD-style popup
instead of stacking. Colour-temperature changes also notify (without the
replace hint).

### Lightweight decoration (UHD 630)

Animations are disabled, windows are opaque (`active/inactive_opacity 1.0`, no
`dim_inactive`), `rounding 0`, `border_size 0`, `gaps_in 5`, `gaps_out 10`,
`allow_tearing false`. Shadow and blur remain off. See `conf/theme.lua` and
`conf/animations.lua`.

## Key map

`Super` is the main modifier.

### Session and applications

| Action | Keybinding |
|---|---|
| Terminal (`kitty herdr`) | `Super + Return` |
| Plain terminal (`kitty`) | `Super + Shift + Return` |
| App launcher (Rofi drun) | `Super + D` |
| App launcher (Tofi) | `Super + Shift + A` |
| Window switcher (Rofi) | `Alt + Tab` / `Alt + Shift + Tab` |
| Cycle windows in workspace | `Super + Tab` / `Super + Shift + Tab` |
| File manager (Nautilus) | `Super + E` |
| Editor (Emacs) | `Super + C` |
| Browser (Brave Origin) | `Super + B` |
| Quran reader | `Alt + Q` |
| Session app | `Super + S` or `Alt + S` |
| Wallpaper picker | `Super + W` |
| Clipboard history | `Super + V` |
| Password store | `Super + Shift + V` |
| Audio mixer (`pavucontrol`) | `Super + A` or `Super + N` |
| Hardware mixer (`alsamixer`) | `Alt + A` |
| Network TUI (`nmtui`) | `Super + J` |
| Do-not-disturb toggle | `Super + I` |
| Colour picker (`hyprpicker -a`) | `Super + P` |
| URL launcher | `Super + U` |
| Timer (`cg-timer`) | `Super + t` |
| Clock (`peaclock`) | `Alt + C` |
| Lock screen | `Super + L` |
| Logout menu | `Super + Esc` |
| Toggle Waybar | `Ctrl + Esc` |
| Reload config | `Super + Shift + R` |
| Power off | `Super + Shift + P` |
| Exit Hyprland | `Super + Shift + M` |

Web-app shortcuts (Brave Origin app windows) live in `conf/keybinds.lua`:
`Alt + T` Telegram, `Alt + R` Reddit, `Alt + F`/`Alt + Shift + F` Facebook,
`Super + Y` YouTube, `Super + T` Twitch, `Super + Shift + W` WhatsApp,
`Super + Shift + D` Discord, `Alt + Shift + D` / `Ctrl + Shift + D` Discord web,
`Super + Shift + F` Magnific, `Alt + E` ev.io.

### Windows and scrolling layout

| Action | Keybinding |
|---|---|
| Close window | `Super + Q` |
| Toggle fullscreen | `Super + F` |
| Toggle floating | `Super + Space` |
| Move window (mouse) | `Super + left-drag` |
| Resize window (mouse) | `Super + right-drag` |
| Focus column left/right | `Super + ←` / `Super + →` |
| Focus column up/down | `Super + Shift + ↑` / `Super + Shift + ↓` |
| Move window left/right | `Super + Shift + ←` / `Super + Shift + →` |
| Move window to previous/next column | `Super + ,` / `Super + .` |
| Swap column with neighbour | `Super + Shift + ,` / `Super + Shift + .` |
| Promote window to a new column | `Super + Shift + ]` |
| Resize column width | `Super + Alt + ,` / `Super + Alt + .` |
| Fit active column to viewport | `Super + \` |
| Scroll columns | `Super + scroll` |
| Swap column via scroll | `Super + Shift + scroll` |
| Resize column via scroll | `Super + Ctrl + scroll` |
| Resize window freely | `Super + Ctrl + arrows` |
| Toggle group/tab mode | `Super + G` |

### Workspaces, monitors and media

| Action | Keybinding |
|---|---|
| Focus workspace 1–10 | `Super + 1` … `Super + 0` |
| Move window to workspace 1–10 | `Super + Shift + 1` … `Super + Shift + 0` |
| Previous/next workspace | `Super + ↑` / `Super + ↓` |
| Previous/next workspace (scroll) | `Alt + Shift + scroll` |
| Previous/next workspace (touchpad) | 3-finger horizontal swipe |
| Rotate active monitor 90° | `Super + Alt + R` (or `Ctrl + Alt + R`) |
| Reset monitor rotation | `Super + Alt + Shift + R` (or `Ctrl + Alt + Shift + R`) |
| Monitor contrast down/up | `Super + F5` / `Super + F6` |
| Next monitor input | `Super + Shift + F5` |
| Volume down/up | `F8` / `F9`, `XF86AudioLowerVolume` / `XF86AudioRaiseVolume` |
| Mute sink | `XF86AudioMute`, `Super + M` |
| Mute/unmute USB mic | `F10`, `XF86AudioMicMute` |
| Play/pause, next, previous | `F11`, `XF86AudioPlay/Pause/Next/Prev` |

### Screenshots, visuals and clipboard

| Action | Keybinding |
|---|---|
| Region screenshot to `~/Pictures/Screenshots` | `Print` or `Super + Print` |
| Full-monitor screenshot | `Shift + Print` |
| Toggle gaps | `Super + Shift + G` |
| Toggle window opacity | `Super + O` |
| E-ink/paper shader toggle | `Super + Shift + E` |
| Night mode (4500 K ↔ 6500 K) | `Super + Shift + N` |
| Screen recording toggle | `Super + R` |

## Function keys

Verified with real `uinput` key events (the same input path as the keyboard),
not with synthetic `wtype` events.

| Key | Action | Backend / status |
|---|---|---|
| `F1` | Default wallpaper | `scripts/set_wallpaper ~/Pictures/wall.jpg` (restarts `swaybg`) |
| `F2` | Warmer colour temperature | `scripts/color_temp warmer` → `hyprctl hyprsunset temperature` (−400 K per press, 3500–7000 K) |
| `Super + F2` | Cooler colour temperature | Same script, +400 K |
| `F3` | “Brightness 100%” | `brightnessctl s 100%` — **caveat:** this desktop has no backlight device, so it targets the LAN LED, not the panel |
| `F4` | Workspace app layout | `scripts/workspace-setup` (spawns the `LAYOUT` array) |
| `F5` / `F6` | External monitor brightness | `scripts/monitor brightness down/up` via `ddcutil-service` (DDC/CI) |
| `F7` | — | Unbound |
| `F8` / `F9` | Volume down/up | `scripts/volume` → `wpctl` + swaync OSD |
| `F10` | USB mic mute toggle | `scripts/input-mute-toggle` → `pactl` + beep + swaync OSD |
| `F11` | Play/pause | `playerctl play-pause` (needs an active player) |
| `F12` | — | Unbound |

`hyprsunset` has no readable temperature property, so `scripts/color_temp` keeps
the last value in `~/.cache/hypr-color-temp`; `scripts/night_mode` shares that
file so both stay in sync.

## Requirements

### Core session

- `hyprland` (0.57.x, Lua config)
- `hypridle`, `hyprlock`
- `xdg-desktop-portal-hyprland`
- `pipewire`, `wireplumber`
- `dbus`, `systemd`
- `fcitx5` (optional input method; environment variables are harmless when it
  is absent)

### Bar, launchers, notifications

- `waybar` (system package, 0.16; **no** patched build)
- `rofi`, `tofi`
- `swaync` — notification daemon and OSD
- `wlogout`
- A Nerd Font for Waybar icons

### Capture and clipboard

- `grim`, `slurp`
- `hyprpicker`
- `wl-clipboard`, `cliphist`

### Wallpaper, media and hardware

- `swaybg`, `imagemagick`
- `playerctl`
- `hyprsunset` (colour temperature)
- `ddcutil` + `ddcutil-service` (external monitor; user must be in the `i2c`
  group)
- `brightnessctl` (only used by `F3`; see caveat above)
- `mpvpaper` (optional animated wallpapers)

### Applications

- `kitty`, `emacs`, `nautilus`, `discord`, `brave-origin`
- `wayland-boomer` (zoom), `cg-timer` (timer) — optional
- `st` — built from `st/` via `./deploy st`

Not part of the session anymore: Ryoku, Quickshell/Shima, `wl-gammarelay-rs`
(one leftover call in `eink-toggle`, see caveats), the patched Waybar build, and
any `qs -c shell` or `ryoku-cmd-*` command.

## Known caveats

- **`F3` has no real target.** This desktop exposes no `/sys/class/backlight`
  device, so `brightnessctl s 100%` changes the LAN LED instead of the panel.
  Remap or remove it if that is not wanted.
- **`F4`, `F7`, `F12`.** `F4` spawns `scripts/workspace-setup`; `F7` and `F12`
  are unbound.
- **E-ink warmth.** `scripts/eink-toggle` toggles the grayscale shader correctly,
  but its warm/brightness step still calls the retired `wl-gammarelay-rs`.
  Use `Super + Shift + N` or `F2` for colour temperature.
- **Idle display power-off.** The lock and suspend listeners in `hypridle.conf`
  work; the `dpms` listeners (15-minute power-off and post-sleep power-on) still
  use the pre-0.57 string form, which this Hyprland rejects. They need the Lua
  dispatcher (`hyprctl dispatch 'hl.dsp.dpms("off")'`).
