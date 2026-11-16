# Neovim configuration

Part of the `~/dotfiles` repo. `./deploy nvim` links `~/.config/nvim` to
`~/dotfiles/.config/nvim`; there is no separate repository to clone.

## Layout

| Path | Purpose |
|---|---|
| `init.lua` | Options, the `Plug()` list, and the `require()` calls. |
| `lua/config/` | `theme`, `mappings`, `options`, `autocmd`, `image_toggle`, `lint`. |
| `lua/plugins/` | One file per plugin, loaded from `init.lua`. |
| `lua/config/mappings.lua` | All keymaps. **Leader is `Space`**; press it alone for which-key. |

## Editing rules

- To add or remove a plugin, edit the `Plug()` list in `init.lua` **and** the
  matching `require("plugins.<name>")`, then run `:PlugInstall` / `:PlugClean`.
- Plugin manager is **vim-plug**, bootstrapped automatically into
  `stdpath('data')/site/autoload/plug.vim` on first start.
- Keep `lua/config/mappings.lua` as the only place keymaps are defined.
- `init.lua` sets `shell = bash` and prepends `~/.config/nvim/node_modules/.bin`
  to `PATH`; keep that ordering, some LSP servers rely on it.

## Checks

```bash
nvim --headless "+lua print('ok')" +qa   # config loads without errors
./deploy nvim                            # (re)install the symlink
```
