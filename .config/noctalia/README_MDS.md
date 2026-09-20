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

## Ambient Sounds (dynamic)
Plugin `hadi/ambient` v2.0.0 (local, `~/.config/noctalia/plugins/hadi-ambient`)
- Catalog is dynamic: every `*.ogg/.oga/.mp3/.wav/.flac/.opus/.m4a` in `sounds/` (bundled, committed) plus custom sounds in plugin data `custom/` (survives updates).
- Bundled: rain, gentle-rain, calming-rain (mpv `--loop`).
- Bar widget `ambient`: click=cycle, right-click=toggle, scroll=volume, middle=open panel. Note `plugin.toml [widget.actions]` keeps only `middle = "none"` so right/middle reach the script.
- Panel `hadi/ambient:ambient-panel`: tap row = play, trash = delete file, input = add local path or URL, Folders = open both dirs, Rescan = re-scan.
- Shortcut tile: add in Noctalia Settings → Control Center → Shortcuts.
- IPC: `noctalia msg plugin hadi/ambient:service all <play|toggle|stop|cycle|volume|set-sound|stop-one|list|rescan|add|remove|open-folder> [value]`
  e.g. `noctalia msg plugin hadi/ambient:service all add ~/Music/ocean.mp3`
  e.g. `noctalia msg plugin hadi/ambient:service all remove ocean`
- Settings: gear on `hadi/ambient` in Settings → Plugins → default_sound (free string), volume, allow_multiple, auto_play.
- Shared scan/label/glyph logic: `plugins/hadi-ambient/lib/sounds.luau` (required by all entries, needs plugin_api ≥ 22).

Deps: `mpv` (installed, declared in manifest). Audio via PipeWire.

Backups in `backups/` (auto on MDS init).
