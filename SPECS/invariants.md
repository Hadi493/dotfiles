# Invariants

Rules that **must not break**. Each one names why it exists and how to check it.
If a change requires breaking one, update this file and the affected specs in
the same commit, and say so in the commit message.

Nine invariants are machine-checked by `./bootstrap/verify.sh`, which the
pre-commit hook runs on every commit. Three cannot be automated without a human
looking at the screen; they are marked manual and must be checked by hand.

| Invariant | Status |
|---|---|
| INV-1 `$HOME/dotfiles` references resolve | automated |
| INV-2 loader is a regular file | automated |
| INV-3 binds use `bind()` | automated |
| INV-4 PATH / no hardcoded home | automated |
| INV-5 one editor variable | automated |
| INV-6 leader keys | **manual** |
| INV-7 clipboard and launchers wired | **manual** (notification daemon automated) |
| INV-8 deploy stays root-free | automated |
| INV-9 no secrets tracked | automated |
| INV-10 startup budget | **manual** |
| INV-11 package coverage | automated |
| INV-12 compositor config verifies | automated |

Manual checks are not optional — they are the ones a reviewer signs off. A green
`./deploy check` means "nothing automated broke", not "the session works".

## INV-1 — The repo lives at `~/dotfiles`

The Hyprland loader, `conf/keybinds.lua`, `hyprlock.conf`, `hypridle.conf`,
`.config/waybar/config.jsonc` and `scripts/lib/wallpaper.sh` resolve
`$HOME/dotfiles/...` absolutely. Renaming or moving the clone breaks the
session even though the symlinks still point somewhere.

**Check:** `grep -rn 'dotfiles' .config/hypr .config/waybar` — every hit must
still resolve. `./deploy check`.

## INV-2 — `~/.config/hypr` is a directory with an installed loader

`~/.config/hypr/hyprland.lua` must be a **regular file** generated from
`.config/hypr/loader.lua`. Never symlink the whole `~/.config/hypr` directory:
Hyprland resolves `require()` relative to the loaded file, so a directory
symlink changes resolution and the `conf/*.lua` tree stops loading.

**Check:** `test -f ~/.config/hypr/hyprland.lua && ! test -L ~/.config/hypr`
`Hyprland --verify-config --config ~/.config/hypr/hyprland.lua` → `config ok`.

## INV-3 — Every Hyprland bind goes through `bind()` in `conf/keybinds.lua`

Hyprland 0.57.2 registers dispatcher-table binds but never fires them
(hyprwm/Hyprland#17425). The local `bind()` wrapper turns dispatch calls into a
raw Lua function. A direct `hl.bind(keys, hl.dsp...)` looks correct in
`hyprctl binds` and is silently dead.

**Check:** `grep -n 'hl\.bind' .config/hypr/conf/keybinds.lua` — only the
wrapper may appear.

## INV-4 — PATH order

`$HOME/.local/bin` comes before system paths, and no file may hardcode
`/home/<user>`. `~/.local/bin` is added once by `environment.d/session.conf`,
once by `.config/fish/config.fish`, and once by `.bashrc`; duplicates are
removed by the fish dedupe block. Do not prepend the same directory again.

**Check:** `./bootstrap/verify.sh` flags foreign `/home/...` paths.
`fish -c 'echo $PATH' | tr " " "\n" | head -1` → `~/.local/bin`.

## INV-5 — One editor, one pager, one editor variable

`EDITOR` and `VISUAL` are `nvim` in `environment.d/session.conf`,
`.config/fish/config.fish` and `.config/fish/user.fish`. Do not reintroduce a
second value in another shell file. (The legacy universal variable
`EDITOR=vim` may still exist in `fish_variables`; the global `set -gx` in
`user.fish` wins. Remove it with `set -e -U EDITOR` if you want a clean state.)

**Check:** `./bootstrap/verify.sh`; `fish -c 'echo $EDITOR'` → `nvim`.

## INV-6 — Leader keys

| Context | Leader | Do not rebind |
|---|---|---|
| Hyprland | `Super` | base for every WM bind |
| Neovim | `Space` | which-key depends on it |
| Emacs | `C-c` / `C-x` | `C-c r`, `C-x c`, `C-x k` are muscle memory |

**Check:** `hyprctl binds | grep -c SUPER`; `nvim` → press `Space`.

## INV-7 — Clipboard and launchers stay wired

- `wf-paste` watchers feed `cliphist`; images go through
  `scripts/clipboard-store` which builds the cached thumbnail.
- `scripts/clipboard` is a **fuzzel** front end and also serves `pass`
  (`Super+Shift+V`). The fuzzel config lives at `.config/fuzzel/fuzzel.ini`;
  deleting it breaks clipboard and password pickers.
- `Super+D` = rofi, `Super+Shift+A` = tofi. Both are intentional; fuzzel is for
  clipboard/pass only.

**Check:** `Super+V`, `Super+Shift+V`, `Super+D`, `Super+Shift+A` all open.

## INV-8 — `deploy` never needs root

`deploy` writes only under `$HOME` (`BIN_DIR` defaults to `~/.local/bin`).
`link_nob` (writes `/usr/include/nob.h`) and `link_st` (network + X11 headers)
are explicit opt-in commands and are excluded from `all`/`config`.

**Check:** `./deploy -h` lists `nob` and `st`; `./deploy all` runs unprivileged.

## INV-9 — Secrets and machine state are never tracked

Never commit credentials, API keys, SSH private keys, GPG material or tokens.
Per-machine overrides go in ignored files:

- `~/.config/hypr/monitors.local.lua` (monitors/outputs)
- `*.local` (e.g. `~/.emacs.local`)
- `~/.config/fish/fish_variables` (already ignored)
- `.freebuff/` (already ignored)

**Check:** `git check-ignore -v <file>`; `git status --short` before committing;
`./bootstrap/verify.sh`.

## INV-10 — Startup performance budget

Target: usable session on the UHD 630 within a few seconds.

- Animations, blur, shadows and rounding are **off** (`conf/animations.lua`,
  `conf/theme.lua`). Do not enable them without measuring.
- Waybar starts after `sleep 1` on purpose; removing it makes waybar exit.
- The clipboard picker must not decode images at open time; thumbnails are
  pre-built by `clipboard-store` in `~/.cache/cliphist-thumbs`.

**Check:** `Hyprland --verify-config`; time from login to a usable bar
(manual), `Super+V` opens instantly.

## INV-11 — Package lists cover every runtime command

Every executable named on `bootstrap/required-commands.txt` must be provided by
`base.txt`, `desktop.txt`, `aur.txt`, a built artifact (`st`) or a vendored
binary in `bin/`.

**Check:** `./bootstrap/verify.sh` reports `missing command: <cmd>`.

## INV-12 — The compositor config must verify

No change to `.config/hypr/**` is complete until Hyprland accepts it.

**Check:** `Hyprland --verify-config --config ~/.config/hypr/hyprland.lua`
and `./deploy check`.
