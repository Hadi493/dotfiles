# Emacs Configuration

Modular Emacs config with multilingual input, custom theme, completion framework, Org-mode, media playback, and broad language support.

## Directory Structure

```
.emacs                 # Entry point, loads everything
.emacs.custom.el       # Customize-saved variables
.emacs.rc/             # Modular configuration files
  rc.el                # Bootstrap: package auto-install
  appearance-rc.el     # Font, theme, modeline, ligatures, vertico
  completion-rc.el     # Helm, Company, Marginalia, Consult, Orderless
  editing-rc.el        # Multiple cursors, whitespace, flyspell, langtool
  programming-rc.el    # Tide, Magit, Git Gutter, Yasnippet, hl-todo
  misc-rc.el           # Utilities: duplicate-line, rgrep, timestamp, etc.
  org-mode-rc.el       # Agenda, capture, clock, org-cliplink
  media-rc.el          # mpv playback via empv (YouTube, files, URLs)
  pdf-rc.el            # pdf-tools with midnight mode
  simpc-rc.el          # simpc-mode loader
  simpc/               # Custom C/C++ major mode
  autocommit-rc.el     # Auto git commit/push on save
  input-methods-rc.el  # Multilingual input (Bangla, Arabic, Urdu)
  arabish.el           # Phonetic Arabic (Arabish)
  urdish.el            # Phonetic Urdu (Urdish)
  gruber-darker-ayu-theme.el  # Custom dark theme
.emacs.snippets/       # Yasnippet snippets
```

## Quick Start

```bash
# Symlink to ~/.emacs
ln -sf ~/dotfiles/emacs.conf/.emacs ~/.emacs
ln -sf ~/dotfiles/emacs.conf/.emacs.rc ~/.emacs.rc
ln -sf ~/dotfiles/emacs.conf/.emacs.custom.el ~/.emacs.custom.el
ln -sf ~/dotfiles/emacs.conf/.emacs.snippets ~/.emacs.snippets
```

First launch auto-installs missing packages from MELPA.

## Appearance

| Setting | Value |
|---------|-------|
| Font | Iosevka Term SS04 18 (Linux) / Iosevka 20 (Windows) |
| Theme | `gruber-darker-ayu` — custom blend |
| Bengali Font | Likhan |
| Icons | Symbols Nerd Font |
| Line Numbers | Relative, global |
| Ligatures | Wide set (`->`, `=>`, `::`, `==`, etc.) |
| Modeline | doom-modeline |

## Keybindings

### General
| Key | Command |
|-----|---------|
| `C-c c` / `C-x c` | `compile` |
| `C-x k` | `kill-compilation` |
| `C-S-k` | `kill-buffer` |
| `C-x C-g` | `find-file-at-point` |
| `C-c i m` | `imenu` |
| `C-,` | `duplicate-line` |
| `C-x p d` | Insert timestamp |
| `C-x p s` | rgrep selected text |
| `C-c M-q` | Unfill paragraph |

### Editing
| Key | Command |
|-----|---------|
| `C-S-c C-S-c` | `mc/edit-lines` |
| `C->` / `C-<` | Mark next/previous like this |
| `M-p` / `M-n` | Move line up/down |
| `C-S-<arrow>` | Resize window |

### Completion
| Key | Command |
|-----|---------|
| `C-c h t` | `helm-cmd-t` |
| `C-c h g g` | `helm-git-grep` |
| `C-c h g l` | `helm-ls-git-ls` |
| `C-c h f` | `helm-find` |
| `C-c h a` | `helm-org-agenda-files-headings` |

### Git
| Key | Command |
|-----|---------|
| `C-c m s` | `magit-status` |
| `C-c m l` | `magit-log` |
| `C-c v n` / `C-c v p` | Next/previous git-gutter hunk |

### Media (mpv)
| Key | Command |
|-----|---------|
| `C-c v y` | YouTube search |
| `C-c v f` | Play file |
| `C-c v u` | Play URL |
| `C-c v t` | Toggle pause/resume |
| `C-c v s` | Seek |

### Org-mode
| Key | Command |
|-----|---------|
| `C-x a` | `org-agenda` |
| `C-c C-x j` | Jump to current clock |
| `C-x p i` | `org-cliplink` (paste URL as Org link) |
| `C-x p t` | Create task from clipboard URL |
| `C-x p w` | Copy heading name |
| `C-cc` | `org-capture` |

### Multilingual Input

| Key | Input Method |
|-----|-------------|
| `C-\` | Toggle input method |
| `C-c b i` | Bengali ITRANS (Banglish) |
| `C-c b p` | Bengali Probhat |
| `C-c b s` | Bengali Inscript |
| `C-c a a` | Arabic (keyboard) |
| `C-c a p` | Arabish (phonetic) |
| `C-c u u` | Urdish (phonetic) |
| `C-c u c` | Urdu Custom |
| `C-c u k` | Urdu Keyboard |
| `C-c u p` | Urdu Phonetic Keyboard |
| `C-c i` | List all input methods |

## Multilingual Input

Type Latin phonetically to get native script. No external IMs (ibus/fcitx) needed.

### Banglish (Bengali ITRANS)
```
ami  -> আমি       bangla -> বাংলা
dhaka -> ঢাকা     bhalo -> ভালো
```

### Arabish (Arabic Phonetic)
```
ana -> انا        kitab -> كتاب
salam -> سلام     shukran -> شكرا
'a -> أ           'i -> إ
```

### Urdish (Urdu Phonetic)
```
salam -> سلام     shukria -> شکریہ
kitab -> کتاب     khuda -> خدا
urdish -> اردش    chand -> چاند
```

## Programming Language Support

C/C++ (`simpc-mode`), Haskell, TypeScript (Tide), Python (elpy), Rust, Go, Scala, OCaml (tuareg), Clojure, Racket, Lua, PHP, PureScript, D, Nim, Nix, Kotlin, GLSL, Dockerfile, YAML, TOML, CMake, Markdown, and more.

## Autocommit System

Automatically commits and pushes git changes on save. Supports per-repo locking, OFFLINE/ONLINE modes, and async git processes.

## Custom Theme

`gruber-darker-ayu` — deep `#181818` background with warm Ayu Dark syntax colors. 748-line theme file covering faces for: Org, Magit, Vertico, Corfu, Consult, Company, Dired, PDF Tools, Avy, Flycheck, Git Gutter, Rainbow Delimiters, Isearch, and more.
