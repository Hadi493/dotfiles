# kitty

## Purpose

Primary terminal (`Super+Return` → `kitty herdr`, `Super+Shift+Return` → plain
`kitty`). `st` is the secondary terminal.

## Files

| Path | Role |
|---|---|
| `.config/kitty/kitty.conf` | Small, hand-written settings + `include`s. |
| `.config/kitty/user.conf` | Loaded last with `globinclude user.conf`; the live font/opacity override. |
| `.config/kitty/current-theme.conf` | Active theme, written by `kitten themes`. |
| `.config/kitty/current-font.conf` | Active font override. |
| `.config/kitty/dark-theme.auto.conf` | Unreferenced by `kitty.conf`; kept for theme tooling. |
| `.config/kitty/themes/gruber-darker-ayu.conf` | Source theme. |

## Load order (matters)

```
kitty.conf
  ├─ include current-theme.conf
  ├─ include current-font.conf
  └─ globinclude user.conf      ← wins
```

`user.conf` sets `font_family` (Iosevka Term SS04), `background_opacity 0.88`
and the keymap overrides. The most recent font is appended to `kitty.conf`
itself (JetBrainsMono), so the effective font is decided by the **last**
`font_family` in load order. If a font change seems ignored, check all four
files before editing.

## Keybindings

| Key | Action |
|---|---|
| `Ctrl+C` | `copy_or_interrupt` (copy on selection, otherwise SIGINT) |
| `Ctrl+Shift+C` / `Ctrl+Shift+V` | copy / paste |
| `Ctrl+ +` / `Ctrl+ -` / `Ctrl+0` | font size |

## Gotchas

- `user.conf` is a 104 KB copy of kitty's upstream sample manual. Only ~10 lines
  are live settings. It is tracked, so `deploy` links it; do not "clean it up"
  without checking which lines are uncommented.
- `current-theme.conf` and `current-font.conf` are written by `kitten themes`
  and are tracked. Re-running a theme switch will dirty the tree.
