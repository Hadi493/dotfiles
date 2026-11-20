# Emacs

## Purpose

Primary GUI editor for notes, Org, PDFs, LaTeX and long-form work
(`Super+C`). Neovim covers quick terminal edits.

## Files

| Path | Role |
|---|---|
| `emacs.conf/.emacs` | Entry point; loads every RC file in order. |
| `emacs.conf/.emacs.custom.el` | `custom-file` (Customize output). |
| `emacs.conf/.emacs.rc/` | Modular config: `rc`, `appearance`, `completion`, `editing`, `programming`, `simpc`, `media`, `pdf`, `misc`, `org-mode`, `autocommit`, `input-methods`, `arabish`, `urdish`, theme. |
| `emacs.conf/.emacs.rc/simpc/` | Custom C/C++ major mode. |
| `emacs.conf/.emacs.rc/compuni/` | Vendored `compuni` package (unicode/emoji insertion). |
| `emacs.conf/.emacs.snippets/` | Yasnippet snippets. |
| `emacs.conf/README.md` | Feature/keybinding reference. |

## Deployment

`deploy` links four paths into `$HOME`: `.emacs`, `.emacs.custom.el`,
`.emacs.rc`, `.emacs.snippets`. Two more are **per-machine and untracked**:

- `~/.emacs.local/` — added to `load-path`, not created by `deploy`.
- `~/.emacs.shadow/shadow-rc.el` — loaded with `t` (no error if missing).

## Dependencies

`emacs`, a Nerd Font, `aspell` + `aspell-en`, `languagetool`, `mpv` (media),
`pdf-tools` (built by Emacs), TeX Live for LaTeX.

## Design decisions

- **MELPA auto-install.** `rc.el` bootstraps `package-initialize` and installs
  missing packages on first launch; the first start is therefore slow.
- **Custom theme** `gruber-darker-ayu-theme.el` is tracked in `.emacs.rc/` and is
  the same palette as kitty/Waybar/fish.
- **Multilingual input** (Bangla, Arabic, Urdu) is loaded last so it can shadow
  default keymaps.
- **Compuni** (`compuni-insert-unicode` / `compuni-insert-emoji`, `C-c u u` /
  `C-c u e`) is vendored in `.emacs.rc/compuni/` because it is not on MELPA;
  it drives `company` as an ephemeral UI. `C-c u u` used to be Urdish, which
  moved to `C-c u r`.
- **`shell-file-name` is `/usr/bin/bash`** even though fish is the login shell.

## Gotchas

- **`autocommit-rc.el` can `git add -A && git commit && git push`.** It is
  opt-in per directory via `rc/autocommit-init-dir` (dir-locals), not global.
  Never enable it in `~/dotfiles`; a save would publish unreviewed config.
- `(setq custom-file "~/.emacs.custom.el")` is loaded twice (set, then
  `load-file` at the end). Harmless, but edits via Customize land in the tracked
  `.emacs.custom.el`.
- `appearance-rc.el` carries Windows font sizes too; keep the Darwin/Win32
  branches if the config is ever used there.

## Check

```bash
emacs --batch -l ~/.emacs --eval '(message "ok")'
```
