# Neovim

## Purpose

Editing for code and config; also the `EDITOR`/`VISUAL` target.

## Files

| Path | Role |
|---|---|
| `.config/nvim/init.lua` | Options, `Plug()` list, `require()` calls. |
| `.config/nvim/lua/config/` | `theme`, `mappings`, `options`, `autocmd`, `image_toggle`, `lint`. |
| `.config/nvim/lua/plugins/` | One module per plugin. |
| `.config/nvim/node_modules/.bin` | Prepended to `PATH` by `init.lua` for local LSP servers. |
| `.config/nvim/README.md` | Layout + editing rules. |

## Dependencies

`neovim`, `ripgrep`, `fd` (fzf-lua), `node`/`npm` for some LSP servers, a Nerd
Font in the terminal.

## Design decisions

- **vim-plug, not lazy.nvim.** `init.lua` bootstraps
  `stdpath('data')/site/autoload/plug.vim` automatically on first start, then
  `PlugInstall --sync`.
- **`Plug()` list and `require()` are mirrored.** Adding a plugin means editing
  both; a `require("plugins.x")` without a `Plug` entry fails at startup.
- **Leader is `Space`** (INV-6). All maps live in `lua/config/mappings.lua`.
- **`shell = bash`** is set explicitly so `:!` commands behave the same in fish
  and bash sessions.
- **`vim.tbl_flatten` shim** keeps older plugin code working on Neovim ≥ 0.11.

## Gotchas

- `lua/plugins/image.lua`, `presence.lua` and `discord.lua` are not loaded
  (their `require()` lines are commented out). Do not assume they are active.
- `alpha.lua` dashboard links point at `~/.local/src`, `~/scripts`; these are
  convenience shortcuts, not dependencies.
- `:PlugClean` deletes plugin directories; run `:PlugInstall` afterwards.

## Check

```bash
nvim --headless "+lua print('ok')" +qa
:checkhealth
```
