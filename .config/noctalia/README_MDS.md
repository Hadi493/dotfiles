# Noctalia MDS — Modular Design System

Entry: `config.toml` (only `[include]`). All design lives in `modules/`.

```
config.toml          # → includes modules/*.toml (autoload=false)
modules/
  00-theme.toml      # theme, shell, shadow, corners, time_format
  10-bar.toml        # bar position, thickness, capsules
  20-widgets.toml    # each widget + [widget.ambient] (hadi/ambient)
  30-system.toml     # wallpaper, lockscreen, notifications
plugins/hadi-ambient/ # ambient sounds plugin (tracked in dotfiles)
palettes/GruberDarker.json
```

## Update anytime
- Change theme: edit `00-theme.toml:1` `custom_palette = "Oxocarbon"`
- Tweak bar: `10-bar.toml:9` `background_opacity`, `radius`, `thickness`
- Clock seconds: `20-widgets.toml:23` `format = "{:%-I:%M:%S %p}"` → remove `:%S` to hide
- Wallpapers: `30-system.toml:2`

`settings.toml` (`~/.local/state/noctalia/settings.toml`) is GUI-owned and wins over modules if same key. Keep overrides minimal or sync them.

Validate: `noctalia config validate` ; export: `noctalia config export > merged.toml`

## Ambient Sounds (macOS-like)
Plugin `hadi/ambient` (local, `~/.local/share/noctalia/plugins/hadi-ambient`)
- Sounds: rain, ocean, stream, forest, fireplace, white-noise, balanced-noise (60s loop ogg in `sounds/`)
- Bar widget `ambient`: click=cycle, right-click=toggle, scroll=volume, middle=open panel
- Panel `hadi/ambient:ambient-panel`: `noctalia msg panel-toggle hadi/ambient:ambient-panel`
- Shortcut tile: add in Noctalia Settings → Control Center → Shortcuts
- IPC: `noctalia msg plugin hadi/ambient:service all <play|toggle|stop|cycle|volume> [value]`
  e.g. `noctalia msg plugin hadi/ambient:service all play rain`
- Settings: gear on `hadi/ambient` in Settings → Plugins → default_sound, volume, allow_multiple, auto_play

Deps: `mpv` (installed). Audio via PipeWire.

Backups in `backups/` (auto on MDS init).
