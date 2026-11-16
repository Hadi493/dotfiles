# Architecture

How this repo is laid out, how it reaches `$HOME`, and how a session starts.

## 1. Repo model

`~/dotfiles` is a **mirror of `$HOME`** for configuration:

```
~/dotfiles/
├── .config/<tool>/        → linked to ~/.config/<tool>
├── .bashrc .gitconfig .vimrc
├── emacs.conf/            → linked piecewise to ~/.emacs*
├── bin/                   → linked to ~/.local/bin/<name>
├── st/                    → built from source, not linked
├── bootstrap/             → package lists + install + verify (not linked)
├── hosts/<hostname>/      → per-machine notes (not linked)
├── legacy/                → archived configs, kept out of `deploy all`
├── SPECS/                 → this documentation
└── deploy                 → the only installer
```

`~/dotfiles` is a **hard invariant**: the Hyprland loader, keybinds, hyprlock,
hypridle, Waybar and the wallpaper library all resolve
`$HOME/dotfiles/...` by absolute path (see `invariants.md`). Do not rename or
relocate the clone without updating those references in the same commit.

There is no Stow, Chezmoi or Nix. `deploy` is a hand-written Bash symlink
manager and is the single supported installation path.

## 2. `deploy`

```bash
./deploy all          # emacs + all config dirs + bin
./deploy -y all       # same, never prompt
./deploy <command>    # one unit: hypr, waybar, kitty, fish, nvim, ...
./deploy check        # run bootstrap/verify.sh
./deploy -h           # command list
```

### `link_one src dst`

This is the primitive every `link_*` function uses:

1. Missing `src` → prints `Skipping (missing)` and returns 0 (never fatal).
2. `dst` exists and is not a symlink → prompts, then moves it to
   `~/.deploy-backup/<name>` (suffixed `.1`, `.2`, … if needed) and links.
   `--yes` skips the prompt. `DEPLOY_BACKUP_DIR` overrides the backup dir.
3. `dst` is already a symlink → replaced directly (`ln -snfv`), no backup.

Re-running any command is safe and idempotent.

### What is linked whole vs. generated

| Unit | Mechanism |
|---|---|
| all `.config/<tool>` dirs | directory symlink → repo directory |
| `.bashrc`, `.vimrc`, `.gitconfig`, `emacs.conf/*` | file symlinks |
| `bin/*` | file symlinks into `$BIN_DIR` (`~/.local/bin`, **never** `/usr/bin`) |
| Hyprland config | **installed loader**, not a symlink |
| `hadi-hyprland.desktop` | **generated** from `.desktop.in` so the paths follow the clone |
| `st` | cloned + patched + compiled into `~/.local/bin/st` (network) |
| `fonts/` | links each file into `~/.local/share/fonts` (currently absent) |

### Deliberately not in `deploy all`

- `./deploy st` — clones `git.suckless.org`, needs X11/Xft headers.
- `./deploy nob` — writes `/usr/include/nob.h`, needs root.
- `./deploy noctalia`, `./deploy swayosd` — legacy, in `legacy/`.
- `./deploy noswaync` — legacy Noctalia helper.

`deploy` itself must never require root.

## 3. Hyprland session, end to end

```
TTY login
  └─ start-hyprland  (or Hyprland)
       └─ ~/.config/hypr/hyprland.lua        ← loader installed by ./deploy hypr
            ├─ package.path += $HOME/dotfiles/.config/hypr/?.lua
            └─ dofile($HOME/dotfiles/.config/hypr/hyprland.lua)
                 ├─ monitors  (or ~/.config/hypr/monitors.local.lua if present)
                 └─ require("conf.variables", "conf.startup", "conf.animations",
                             "conf.input", "conf.theme", "conf.window_rules",
                             "conf.keybinds")
```

Why a loader: Hyprland resolves `require()` relative to the file it was given.
Symlinking the whole `~/.config/hypr` directory breaks that resolution, so the
installed file is a 7-line shim. Never replace it with a directory symlink.

`hypridle.conf` and `hyprlock.conf` are separate programs and are invoked with
explicit `~/dotfiles/...` paths.

### Startup sequence (`conf/startup.lua`, `hyprland.start`)

1. `fcitx5 -d` — only if `fcitx5` is on `PATH`; its env vars are exported only then.
2. `wl-paste --type text --watch cliphist store`
3. `wl-paste --type image --watch scripts/clipboard-store`
4. `sh -c 'sleep 1; exec waybar'` — the 1 s delay lets the IPC socket come up.
5. `scripts/restore_wallpaper` (swaybg / mpvpaper).
6. `dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP`
7. `scripts/run_hypridle`
8. `scripts/break &`
9. `hyprsunset` if not already running.
10. `scripts/unmute_mic.sh`

**swaync is not started here.** It is an enabled systemd user unit and owns
`org.freedesktop.Notifications`; starting it twice makes the unit fail.

`hyprctl reload` re-runs these handlers, so expect bar/daemon respawns.

## 4. Packages

`bootstrap/` is the install path; it is independent of `deploy`.

```bash
./bootstrap/install-packages.sh --dry-run --all   # print the commands
./bootstrap/install-packages.sh --all             # pacman + AUR helper
./bootstrap/verify.sh                             # read-only health check
./bootstrap/verify.sh -v                          # per-check output
```

- `bootstrap/packages/base.txt` — base system.
- `bootstrap/packages/desktop.txt` — everything the configs call at runtime.
- `bootstrap/packages/aur.txt` — AUR-only (verified with `pacman -Si`).
- `bootstrap/required-commands.txt` — commands `verify.sh` must find on `PATH`.

`legacy/packages.system.pkglist` and `legacy/aur.system.pkglist` are the old
whole-machine `pacman -Qqe` dumps. They are reference material only: they
contain KDE, MATE, Xorg, i3 and unrelated tooling and must not be installed
wholesale.

Adding a runtime dependency means: add the package to `desktop.txt` or
`aur.txt`, add the command to `required-commands.txt`, then run
`./bootstrap/verify.sh`.

## 5. Git history, branches and blobs

The working branch is `hypr`.

`.git` was 327 MB because `fonts/IosevkaCurlySlab-*.ttc` (45–47 MB each) were
committed on the old `i3` branch. `fonts/` is gitignored and does not exist in
the working tree, so those blobs were reachable only through that branch.

On 2026-11-17 the local `i3` branch and its tracking ref were dropped, then:

```bash
git reflog expire --expire-unreachable=now --all
git gc --prune=now
```

and the fetch refspec was narrowed so a plain `git fetch` cannot pull the fonts
back:

```
remote.origin.fetch = +refs/heads/hypr:refs/remotes/origin/hypr
                      +refs/heads/master:refs/remotes/origin/master
```

`.git` is ~31 MB now. `i3` still exists on the forges; to get it back:

```bash
git config --add remote.origin.fetch '+refs/heads/i3:refs/remotes/origin/i3'
git fetch origin i3
git branch i3 origin/i3
```

Rules:

- Never `git add -f` anything under `fonts/` or another ignored bulk directory.
- `bin/` still carries `yay` (9 MB), `paru` (7.7 MB) and `toofan` (4.8 MB);
  they are vendored on purpose because no package provides them.
- Do not rewrite history of `hypr` to shrink it further without an explicit
  decision: four remotes would need a force-push.

## 6. Adding a new tool

1. Put its config at `.config/<tool>/` (or a single tracked file).
2. Add a `link_<tool>()` function in `deploy` using `link_one`.
3. Add it to `link_config` (or to `link_all` if it needs a special case).
4. Add the command to `bootstrap/required-commands.txt` and the package to
   `bootstrap/packages/desktop.txt`.
5. Add `SPECS/tools/<tool>.md` if it has keybindings or non-obvious behaviour.
6. Run `./deploy <tool>` and `./deploy check`.
