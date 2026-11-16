# fish configuration

Part of `~/dotfiles`; `./deploy fish` links `~/.config/fish` here. Do **not**
delete `~/.config/fish` and clone a separate repo over it — that removes the
dotfiles-managed config and the `user.fish` layer.

## Load order

```
conf.d/*.fish      (fish-generated migrations, deno/rustup env, desktop display)
config.fish        shipped: PATH, tool hooks, colours, greeting
  └─ user.fish     personal additions, loaded last and wins
```

## Files

| Path | Role |
|---|---|
| `config.fish` | Shipped config. Conditional hooks for starship, zoxide, mise, fzf, eza, fd, fastfetch. |
| `user.fish` | Personal aliases/functions/prompt. Tracked, but treat as the local override layer. |
| `conf.d/` | `deno.fish`, `rustup.fish` (source only if installed), `desktop-display.fish` (heals DISPLAY in tmux/herdr panes). |
| `themes/gruber-darker-ayu.fish` | Palette, sourced from `user.fish`. |
| `functions/` | `bind_M_n_history`, `fzf/*`. |
| `fish_variables` | Universal variables — ignored, never commit. |

Full spec: [`SPECS/tools/fish.md`](../../SPECS/tools/fish.md).

## Check

```bash
fish -n ~/.config/fish/config.fish ~/.config/fish/user.fish
```
