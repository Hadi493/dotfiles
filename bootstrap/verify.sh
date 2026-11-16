#!/usr/bin/env bash
# Health check for the dotfiles repo and the installed session.
#
#   ./bootstrap/verify.sh          # summary, non-zero exit on failure
#   ./bootstrap/verify.sh -v       # list every check
#
# Checks: shell/Lua syntax, required commands, deployed symlinks, hardcoded
# home paths, and the Hyprland config. Read-only.

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

section "hardcoded home paths"

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

section "hyprland"

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
