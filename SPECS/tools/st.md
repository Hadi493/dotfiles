# st (suckless terminal)

## Purpose

Secondary terminal, built from source with the alpha patch so it can sit on the
desktop at 0.88 opacity with the Gruber Darker Ayu palette. Primary terminal is
kitty.

## Files

| Path | Role |
|---|---|
| `st/build.sh` | Clone → patch → build → install. |
| `st/config.h` | Theme and font (Iosevka Term SS04, alpha 0.88). |
| `st/st-alpha-0.8.5.diff` | Alpha patch. |

## Build

```bash
./deploy st        # or: bash st/build.sh
```

What it does:

1. Checks `make`, `pkg-config`, X11/Xft and fontconfig headers.
2. Clones `https://git.suckless.org/st` at tag `0.8.5` into
   `${ST_BUILD_DIR:-/tmp/st-build}`.
3. Applies `st-alpha-0.8.5.diff`.
4. Copies `config.h` over the upstream one and touches it so `make` keeps it.
5. Builds and installs to `${INSTALL_DIR:-$HOME/.local}/bin/st`.
6. Installs terminfo with `tic -sx` into `$HOME/.terminfo`.

## Dependencies

`git`, `make`, a C compiler, `libxft`/`fontconfig` headers, `ncurses` (`tic`).

## Design decisions

- **Not in `deploy all`.** It needs the network and X11 headers, so it is an
  explicit opt-in command (INV-8).
- **X11 client on a Wayland session.** st runs through XWayland; it is kept for
  the alpha patch, which kitty does not need.
- **No runtime config file.** All changes go in `config.h` and require a rebuild.
- **`-A` override.** `st -A 0.x` overrides the 0.88 default when a compositor
  already applies opacity.

## Gotchas

- `config.h` is copied **after** cloning; `touch` is required or `make` rebuilds
  with the upstream default config.
- The build directory is wiped on every run (`rm -rf "$BUILD_DIR"`).
- `st` is a floating window by rule in `conf/window_rules.lua` (class
  `st-256color`).
