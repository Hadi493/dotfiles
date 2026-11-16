# fish

## Purpose

Primary interactive shell. Bash exists for scripts and the occasional login
shell; nushell is installed but secondary.

## Files

| Path | Role |
|---|---|
| `.config/fish/config.fish` | Shipped config: PATH, tool hooks, colours, greeting. |
| `.config/fish/user.fish` | Personal additions, loaded **last** (`source` at the end of `config.fish`), so it wins. Tracked, despite the old "never shipped" comment. |
| `.config/fish/conf.d/` | `deno.fish`, `rustup.fish`, `desktop-display.fish`, two fish-generated migration files. |
| `.config/fish/themes/gruber-darker-ayu.fish` | Palette. |
| `.config/fish/functions/` | `bind_M_n_history`, `fzf/*`. |
| `fish_variables` | Universal variables — **ignored**, never commit. |

## Load order

```
conf.d/*.fish            (alphabetical; fish-generated theme + key bindings)
config.fish
  └─ user.fish           (last, wins)
```

## Design decisions

- **`$HOME/.local/bin` first on PATH**, added with `fish_add_path` (idempotent).
  No hardcoded `/home/<user>` (INV-4).
- **Tool hooks are conditional**: starship, zoxide, mise, fzf, eza, fd, fastfetch
  are sourced/aliased only when the binary exists.
- **Colours are pinned in `config.fish`** because the old palette-tied default
  made typed input the same colour as the background. `user.fish` then sources
  the Gruber Darker Ayu theme. `conf.d/fish_frozen_theme.fish` is a fish 4.3
  migration artifact; it loads before both and is overridden.
- **`user.fish` uses `set -gx`, not `set -Ux`.** Universal variables persist in
  `fish_variables` (ignored), which made the shell state non-reproducible.
- **Custom `fish_prompt`.** `config.fish` sources starship if present, but
  `user.fish` defines `fish_prompt` last, so the custom prompt is what you see.
  Removing one without the other leaves a dormant dependency.

## Gotchas

- A stale universal `EDITOR=vim` may still exist from before; the global
  `set -gx EDITOR nvim` in `user.fish` wins (INV-5).
- `desktop-display.fish` heals `DISPLAY`/`WAYLAND_DISPLAY` inside herdr/tmux
  panes started before the desktop. It mentions Turnstile/`/run/user`; it is
  harmless on Arch.
- Never edit `fish_variables` by hand; use `set -U` / `set -e -U`.

## Check

```bash
fish -n ~/.config/fish/config.fish ~/.config/fish/user.fish
fish -c 'echo $EDITOR; echo $PATH'
```
