#!/usr/bin/env bash
# Health check for the dotfiles repo and the installed session.
#
#   ./bootstrap/verify.sh          # summary, non-zero exit on failure
#   ./bootstrap/verify.sh -v       # list every check
#
# Automated invariants (see SPECS/invariants.md):
#   INV-1  every ~/dotfiles/... reference resolves
#   INV-2  ~/.config/hypr is a directory with an installed loader
#   INV-3  no bind bypasses the bind() wrapper
#   INV-4  no hardcoded /home/<user>
#   INV-5  EDITOR/VISUAL are nvim everywhere
#   INV-8  deploy touches no system path and never uses sudo
#   INV-9  no secrets or machine state are tracked
#   INV-11 every required command exists
#   INV-12 the compositor config verifies
#
# Plus: shell/Lua syntax and the deployed symlinks. Read-only.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERBOSE=0
[ "${1:-}" = "-v" ] && VERBOSE=1

fail=0

ok()   { [ "$VERBOSE" -eq 1 ] && printf 'ok    %s\n' "$1"; return 0; }
bad()  { printf 'FAIL  %s\n' "$1"; fail=$((fail + 1)); }
skip() { [ "$VERBOSE" -eq 1 ] && printf 'skip  %s\n' "$1"; return 0; }

section() { [ "$VERBOSE" -eq 1 ] && printf '\n== %s ==\n' "$1"; return 0; }

section "syntax"

while IFS= read -r f; do
    case "$f" in
        *.sh|*/deploy|*/scripts/*|bin/cgm)
            [ -f "$ROOT/$f" ] || continue
            head -1 "$ROOT/$f" | grep -qE '(bash|sh)$' || continue
            bash -n "$ROOT/$f" 2>/dev/null && ok "bash $f" || bad "bash syntax: $f"
            ;;
    esac
done < <(cd "$ROOT" && git ls-files)

while IFS= read -r f; do
    fish -n "$ROOT/$f" 2>/dev/null && ok "fish $f" || bad "fish syntax: $f"
done < <(cd "$ROOT" && git ls-files '*.fish')

if command -v luac >/dev/null 2>&1; then
    while IFS= read -r f; do
        luac -p "$ROOT/$f" 2>/dev/null && ok "lua $f" || bad "lua syntax: $f"
    done < <(cd "$ROOT" && git ls-files '.config/hypr/*.lua')
else
    skip "luac not installed"
fi

section "required commands"

while IFS= read -r cmd; do
    case "$cmd" in ''|'#'*) continue ;; esac
    if command -v "$cmd" >/dev/null 2>&1; then
        ok "command $cmd"
    else
        bad "missing command: $cmd"
    fi
done < "$ROOT/bootstrap/required-commands.txt"

section "deployed symlinks"

# Every .config subdirectory is linked whole, except:
#   hypr  - installed as a loader (INV-2)
#   tmux  - only tmux.conf is linked
while IFS= read -r dir; do
    name="$(basename "$dir")"
    case "$name" in hypr) skip "hypr uses an installed loader"; continue ;; esac
    case "$name" in tmux) target="$HOME/.config/tmux/tmux.conf" ;; *) target="$HOME/.config/$name" ;; esac
    src="$ROOT/$dir"
    case "$name" in tmux) src="$ROOT/.config/tmux/tmux.conf" ;; esac

    if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$src")" ]; then
        ok "link $target"
    elif [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ]; then
            ok "link $target (other target)"
        else
            bad "not a symlink: $target (run ./deploy $name)"
        fi
    else
        bad "missing link: $target (run ./deploy $name)"
    fi
done < <(cd "$ROOT" && find .config -mindepth 1 -maxdepth 1 -type d | sort)

for f in .bashrc .vimrc .gitconfig; do
    if [ -L "$HOME/$f" ]; then
        ok "link $HOME/$f"
    else
        bad "missing symlink: $HOME/$f"
    fi
done

section "INV-1 dotfiles references resolve"

# Absolute references into this clone. A path may legitimately continue past a
# space or a shell variable, so a unique prefix also counts as resolved.
missing_refs=0
while IFS= read -r ref; do
    rel="${ref#*dotfiles/}"
    target="$HOME/dotfiles/$rel"
    if [ -e "$target" ]; then
        ok "ref $rel"
    elif compgen -G "$target*" >/dev/null 2>&1; then
        ok "ref $rel (prefix)"
    else
        bad "INV-1: $ref does not exist"
        missing_refs=$((missing_refs + 1))
    fi
done < <(grep -rIh 'dotfiles/' "$ROOT/.config/hypr" "$ROOT/.config/waybar" \
            --exclude='*.md' 2>/dev/null \
        | grep -vE '^[[:space:]]*(--|#|//)' \
        | grep -oE '(~/|\$HOME/|"/)dotfiles/[A-Za-z0-9._/-]+' \
        | sort -u)

[ "$missing_refs" -eq 0 ] && ok "all tracked references resolve"

section "INV-2 loader is an installed file"

if [ -L "$HOME/.config/hypr" ]; then
    bad "INV-2: ~/.config/hypr is a symlink; it must be a directory (run ./deploy hypr)"
elif [ ! -f "$HOME/.config/hypr/hyprland.lua" ]; then
    bad "INV-2: ~/.config/hypr/hyprland.lua missing (run ./deploy hypr)"
elif [ -L "$HOME/.config/hypr/hyprland.lua" ]; then
    bad "INV-2: hyprland.lua is a symlink; install the loader with ./deploy hypr"
else
    ok "INV-2 loader installed"
fi

section "INV-3 binds use bind()"

binds_file="$ROOT/.config/hypr/conf/keybinds.lua"
if grep -qE 'hl\.bind[[:space:]]*\(' "$binds_file" 2>/dev/null; then
    bad "INV-3: direct hl.bind(...) in keybinds.lua (Hyprland 0.57 drops it; use bind())"
elif ! grep -q 'local hl_bind = hl.bind' "$binds_file" 2>/dev/null; then
    bad "INV-3: bind() wrapper is missing from keybinds.lua"
else
    ok "INV-3 all binds go through bind()"
fi

section "INV-5 EDITOR/VISUAL"

bad_editor=0
for f in .bashrc .config/fish/config.fish .config/fish/user.fish .config/environment.d/session.conf; do
    [ -f "$ROOT/$f" ] || continue
    while IFS= read -r hit; do
        case "$hit" in
            *EDITOR*nvim*|*VISUAL*nvim*) ok "$f: $hit" ;;
            *) bad "INV-5: $f sets a non-nvim editor: $hit" ; bad_editor=1 ;;
        esac
    done < <(grep -nE '(^|[^[:alnum:]_])(EDITOR|VISUAL)[[:space:]]*[= ]' "$ROOT/$f" 2>/dev/null)
done
[ "$bad_editor" -eq 0 ] && ok "INV-5 EDITOR/VISUAL are nvim"

section "INV-8 deploy stays root-free"

bad_deploy=0
if grep -qE '(^|[^[:alnum:]_])sudo([^[:alnum:]_]|$)' "$ROOT/deploy" 2>/dev/null; then
    bad "INV-8: deploy mentions sudo; it must never need root"
    bad_deploy=1
fi
while IFS= read -r line; do
    bad "INV-8: deploy touches a system path: $line"
    bad_deploy=1
done < <(grep -nE '/usr/|/etc/' "$ROOT/deploy" 2>/dev/null \
        | grep -vE '^[0-9]+:[[:space:]]*#' \
        | grep -v '^1:#!/' \
        | grep -v 'nob\.h')
[ "$bad_deploy" -eq 0 ] && ok "INV-8 deploy only writes under \$HOME"

section "INV-9 no secrets tracked"

secret_hits="$(cd "$ROOT" && git ls-files 2>/dev/null \
    | grep -E '(^|/)(fish_variables|\.env(\..+)?|id_(rsa|ed25519|ecdsa)|secrets?/)|\.(pem|key|p12|kdbx|local)$' \
    | grep -v '^\.local/' || true)"
if [ -n "$secret_hits" ]; then
    while IFS= read -r f; do
        bad "INV-9: sensitive file is tracked: $f"
    done <<< "$secret_hits"
else
    ok "INV-9 no secrets or machine state tracked"
fi

section "INV-4 hardcoded home paths"

# Only runtime files: docs and legacy are allowed to mention /home/<user>.
# Ignored machine state (fish_variables) is not part of the repo contract.
while IFS= read -r line; do
    content="${line#*:*:}"
    rest="${content//$HOME/}"
    case "$rest" in
        *"/home/"*) bad "hardcoded path: $line" ;;
        *) ok "path ok: $line" ;;
    esac
done < <(cd "$ROOT" && grep -rIn '/home/' \
            .config .bashrc .vimrc bin deploy st .local \
            --exclude='*.md' --exclude='fish_variables' 2>/dev/null \
            | grep -vE ':[0-9]+:[[:space:]]*#')

section "INV-12 compositor config"

if command -v Hyprland >/dev/null 2>&1 && [ -f "$HOME/.config/hypr/hyprland.lua" ]; then
    if timeout 30 Hyprland --verify-config --config "$HOME/.config/hypr/hyprland.lua" >/dev/null 2>&1; then
        ok "Hyprland config"
    else
        bad "Hyprland --verify-config failed"
    fi
else
    skip "Hyprland or loader not installed"
fi

printf '\n'
if [ "$fail" -eq 0 ]; then
    echo "verify: all checks passed"
else
    echo "verify: $fail problem(s)"
fi
exit "$([ "$fail" -eq 0 ] && echo 0 || echo 1)"
