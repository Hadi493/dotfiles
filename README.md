# Hadi's dotfiles

Personal configuration for a lightweight **Hyprland** desktop on Arch Linux.
`~/dotfiles` is the single source of truth: the session runs from this tree
directly, with no Ryoku, no Quickshell, no display manager and no Nix.

- **WM:** Hyprland 0.57 (Lua config, built-in scrolling/niri-like layout)
- **Bar:** Waybar 0.16 (system package)
- **Notifications/OSD:** swaync
- **Launchers:** Rofi (drun), Tofi (fast drun), fuzzel (clipboard + `pass`)
- **Lock/idle:** hyprlock + hypridle
- **Terminals:** kitty (primary), st (built from `st/`)
- **Editors:** Neovim, Emacs, Helix
- **Shells:** fish (primary), nushell, bash

## Fresh machine

```bash
git clone <this repo> ~/dotfiles      # path is an invariant, keep it
cd ~/dotfiles

# 1. packages (prints commands first)
./bootstrap/install-packages.sh --dry-run --all
./bootstrap/install-packages.sh --all

# 2. link configs (no root needed)
./deploy hypr          # installed loader + session entry
./deploy all           # emacs, every .config dir, bin -> ~/.local/bin

# 3. optional extras
./deploy st            # suckless st (clones + patches + builds)
./deploy swaync        # link + enable the systemd user unit

# 4. check
./deploy check
```

Then log in on a TTY and run `start-hyprland` (or `Hyprland`).

`deploy` backs up any existing non-symlink destination to `~/.deploy-backup/`
and asks before replacing it; `-y` skips the prompt.

## How the session boots

```
TTY login
  └─ start-hyprland / Hyprland
       └─ ~/.config/hypr/hyprland.lua        (loader installed by ./deploy hypr)
            └─ ~/dotfiles/.config/hypr/hyprland.lua
                 └─ conf/{variables,startup,animations,input,theme,
                          window_rules,keybinds}.lua
```

The loader (not a symlink) is required because Hyprland resolves `require()`
relative to the file it loads. Never symlink the whole `~/.config/hypr` dir.

```bash
Hyprland --verify-config --config ~/.config/hypr/hyprland.lua   # -> config ok
hyprctl reload                                                   # apply changes
```

Monitor defaults live in `hyprland.lua`; per-machine overrides go in the
untracked `~/.config/hypr/monitors.local.lua`.

## Keybindings

Modifier is `Super`. Full map: [`.config/hypr/README.md`](.config/hypr/README.md).

| Action | Key |
|---|---|
| Terminal (`kitty herdr`) / plain kitty | `Super+Return` / `Super+Shift+Return` |
| App launcher (Rofi) / (Tofi) | `Super+D` / `Super+Shift+A` |
| Cycle windows (global MRU) | `Alt+Tab` / `Alt+Shift+Tab` |
| File manager / Editor / Browser | `Super+E` / `Super+C` / `Super+B` |
| Wallpaper picker | `Super+W` |
| Clipboard / manage / passwords | `Super+V` / `Super+Alt+V` / `Super+Shift+V` |
| Notification panel / DND | `Super+N` / `Super+I` |
| Audio mixer / hardware mixer | `Super+A` / `Alt+A` |
| Lock / logout menu | `Super+L` / `Super+Esc` |
| Toggle Waybar | `Ctrl+Esc` |
| Reload config | `Super+Shift+R` |
| Screenshot (flameshot) | `Print` |
| Volume down/up, mic mute | `F8`/`F9`, `F10` |
| Brightness/contrast (DDC), colour temp | `F5`/`F6`, `F2`/`Super+F2` |
| Power off / exit session | `Super+Shift+P` / `Super+Shift+M` |

Scrolling layout: `Super+←/→` focus columns, `Super+Shift+←/→` move windows,
`Super+,` / `Super+.` move between columns, `Super+Alt+,` / `Super+Alt+.` resize,
`Super+\` fit column, `Super+scroll` scroll columns. Workspaces: `Super+1..0`,
`Super+↑/↓` previous/next, 3-finger horizontal swipe.

## Repository layout

| Path | Contents |
|---|---|
| `.config/hypr/` | Compositor config, session scripts, key map docs |
| `.config/{waybar,swaync,rofi,tofi,fuzzel}/` | Bar, notifications, launchers |
| `.config/{kitty,alacritty}/`, `st/` | Terminals |
| `.config/{nvim,helix,vis}/`, `emacs.conf/`, `.vimrc` | Editors |
| `.config/{fish,nushell}/`, `.bashrc` | Shells |
| `.config/{btop,cava,mpv,fastfetch,tmux,flameshot,wlogout,pipewire,environment.d}/` | Misc |
| `bin/` | Vendored helpers, linked into `~/.local/bin` |
| `bootstrap/` | Package lists, installer, `verify.sh` |
| `hosts/<hostname>/` | Per-machine notes |
| `legacy/` | Archived Noctalia/swayosd configs and old package dumps |
| `SPECS/` | Architecture, invariants and per-tool specs |

## Documentation

- [`AGENTS.md`](AGENTS.md) — rules for AI agents and humans changing this repo.
- [`SPECS/architecture.md`](SPECS/architecture.md) — deploy, boot chain, packages.
- [`SPECS/invariants.md`](SPECS/invariants.md) — what must not break.
- [`SPECS/tools/`](SPECS/tools/) — one spec per major tool.
- [`.config/hypr/README.md`](.config/hypr/README.md) — full key map and caveats.

## Legacy

`legacy/` holds configurations that are no longer part of the session:
Noctalia (a Quickshell shell), swayosd, and the old whole-machine package dumps.
They are installable explicitly (`./deploy noctalia`, `./deploy swayosd`) but
are not linked by `./deploy all`.

## Notes

- Hyprland 0.57 silently drops dispatcher-table binds; every bind goes through
  the `bind()` helper in `conf/keybinds.lua`.
- `F3` maps to `brightnessctl`, but this machine has no backlight device.
- Emacs autocommit can commit and push on save when enabled per directory;
  never enable it for this repository.
