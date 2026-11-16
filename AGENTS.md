# AGENTS.md

Instructions for AI agents (and humans) maintaining this repository. Read
`SPECS/architecture.md` and `SPECS/invariants.md` before changing anything.

## What this repo is

Personal dotfiles for a Hyprland 0.57 desktop on Arch (`cyber-green`).
`~/dotfiles` mirrors `$HOME`; `./deploy` symlinks it into place. There is no
Stow, Chezmoi, Nix or display manager.

```
~/.config/<tool>/  ← symlink →  ~/dotfiles/.config/<tool>/
~/.bashrc          ← symlink →  ~/dotfiles/.bashrc
~/.local/bin/*     ← symlink →  ~/dotfiles/bin/*
~/.config/hypr/hyprland.lua  ← generated loader (NOT a symlink)
```

## Hard rules

1. **Never hardcode `/home/<user>`.** Use `$HOME`, `os.getenv("HOME")`, or the
   `DOTFILES_DIR` variable in `deploy`. The only allowed absolute prefix is
   `$HOME/dotfiles` — and only where an app cannot expand variables (desktop
   entry, Hyprland IPC). `./deploy check` fails on foreign `/home/...` paths.
2. **Never symlink `~/.config/hypr`.** Install the loader with
   `./deploy hypr`. Hyprland resolves `require()` relative to the loaded file.
3. **All Hyprland binds use the local `bind()` wrapper** in
   `conf/keybinds.lua`. Direct dispatcher-table binds are silently dead on 0.57.
4. **`deploy` must stay root-free.** No writes to `/usr/bin`, `/usr/include` or
   `/etc`. `st` and `nob` are explicit opt-in commands.
5. **Never commit secrets or machine state.** No tokens, keys, passwords, GPG
   material, `fish_variables`, `*.local`, `.freebuff/`, or cache files.
   Per-machine overrides belong in ignored files (see *Secrets* below).
6. **Do not rename or move the clone.** `$HOME/dotfiles` is an invariant.
7. **Test shell syntax before finishing:** `bash -n`, `fish -n`, `luac -p`.
8. **Verify the compositor config:** `Hyprland --verify-config --config
   ~/.config/hypr/hyprland.lua` must print `config ok`.
9. **Do not delete `legacy/` or `bin/` without asking.** `legacy/` is archived
   on purpose; `bin/` holds vendored binaries that some keybinds call.
10. **Do not touch uncommitted work.** Run `git status` first; if files are
    already modified, treat those edits as the user's and leave them alone.
11. **No drive-by refactors.** Change only what the task needs. If the scope
    grows, stop and say so.
12. **Every claim needs a check.** Report the command you ran and its output.

## Repo map

| Path | What it is | Linked to |
|---|---|---|
| `.config/hypr/` | compositor Lua tree + session scripts | via loader + Waybar/desktop paths |
| `.config/waybar/` | bar | `~/.config/waybar` |
| `.config/swaync/` | notifications/OSD | `~/.config/swaync` |
| `.config/{rofi,tofi,fuzzel}/` | launchers | same names |
| `.config/kitty/`, `st/` | terminals | `~/.config/kitty`, st built to `~/.local/bin` |
| `.config/{nvim,helix,vis}/`, `emacs.conf/`, `.vimrc` | editors | same names / `~/.emacs*` |
| `.config/{fish,nushell}/`, `.bashrc` | shells | same names |
| `.config/{btop,cava,mpv,fastfetch,tmux,flameshot,wlogout,alacritty,pipewire,environment.d}` | misc apps | same names |
| `bin/` | vendored binaries (`paru`, `yay`, `cg-timer`, `toofan`, `wayland-boomer`, `wal`, `cgm`) | `~/.local/bin` |
| `bootstrap/` | package lists, installer, verifier | not linked |
| `hosts/<hostname>/` | per-machine notes | not linked |
| `legacy/` | Noctalia, swayosd, old package dumps | opt-in only |
| `SPECS/` | architecture + invariants + tool specs | not linked |
| `deploy` | the installer | – |

## Commands

```bash
./deploy              # link everything (emacs + config + bin)
./deploy -y all       # no prompts
./deploy <unit>       # hypr, waybar, swaync, kitty, fish, nvim, ...
./deploy check        # health check (syntax, commands, symlinks, Hyprland)
./bootstrap/verify.sh -v
./bootstrap/install-packages.sh --dry-run --all
```

## Where does a change go?

| Change | File |
|---|---|
| Keybinding | `.config/hypr/conf/keybinds.lua` (use `bind()`) + the key table in `.config/hypr/README.md` |
| Program used by a bind | `.config/hypr/conf/variables.lua` (`P.*`) |
| Autostart / session env | `.config/hypr/conf/startup.lua` |
| Gaps/opacity/layout | `.config/hypr/conf/theme.lua` |
| Window float/size rule | `.config/hypr/conf/window_rules.lua` |
| Monitor/output | `~/.config/hypr/monitors.local.lua` (untracked) |
| Shell behaviour | `.config/fish/config.fish` (shipped) / `user.fish` (personal) |
| New package | `bootstrap/packages/*.txt` + `bootstrap/required-commands.txt` |
| New linked config | `.config/<tool>/` + `link_<tool>()` in `deploy` + add to `link_config` |
| New tool docs | `SPECS/tools/<tool>.md` |

## Secrets and machine state

Never tracked; already gitignored:

- `~/.config/hypr/monitors.local.lua` — monitor overrides
- `~/.config/fish/fish_variables` — fish universal variables
- `*.local`, `.freebuff/`, `*.bak`, `*.backup`, `*~`
- `.config/nushell/history.txt`, caches

If a new secret is needed, put it in an ignored `*.local` file or
`~/.config/secrets/` (create it outside the repo) and reference it by path.

## Known traps

- **Hyprland 0.57 bind bug** (hyprwm/Hyprland#17425): use `bind()`.
- **Waybar needs `sleep 1`** before start; removing it makes waybar exit.
- **swaync is a systemd unit**, not a startup command; starting it twice fails.
- **`Print` runs flameshot**, not grim/slurp. The old binds are commented out.
- **`F3` has no backlight device** on this machine.
- **Emacs autocommit** can `commit && push` on save when enabled per-directory.
  Never enable it for this repo.
- **Kitty font** is set in four files; the last one wins. Check all before
  editing.
- **`bin/wlogout` is the packaged binary's twin**; `deploy` no longer links it.

## Definition of done

1. `git status --short` shows only intended changes.
2. `bash -n` / `fish -n` / `luac -p` pass for every edited file.
3. `./deploy check` passes (or the only failures are pre-existing and named).
4. Hyprland config verifies if `.config/hypr/**` changed.
5. The relevant `SPECS/` page is updated in the same commit.
6. The commit message says what changed and why.
