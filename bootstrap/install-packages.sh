#!/usr/bin/env bash
# Install the curated package sets. This is a bootstrap helper, not part of
# ./deploy: it only runs pacman and never touches files in your home.
#
#   ./bootstrap/install-packages.sh --base      # system packages
#   ./bootstrap/install-packages.sh --desktop   # desktop session
#   ./bootstrap/install-packages.sh --aur       # AUR packages (needs paru/yay)
#   ./bootstrap/install-packages.sh --all
#
# Pass --dry-run to print the command without running it.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
DO_BASE=0
DO_DESKTOP=0
DO_AUR=0

for arg in "$@"; do
    case "$arg" in
        --base)    DO_BASE=1 ;;
        --desktop) DO_DESKTOP=1 ;;
        --aur)     DO_AUR=1 ;;
        --all)     DO_BASE=1; DO_DESKTOP=1; DO_AUR=1 ;;
        --dry-run) DRY_RUN=1 ;;
        -h|--help)
            sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) echo "unknown option: $arg" >&2; exit 2 ;;
    esac
done

if [ $((DO_BASE + DO_DESKTOP + DO_AUR)) -eq 0 ]; then
    echo "nothing selected; use --base, --desktop, --aur or --all" >&2
    exit 2
fi

run() {
    printf '+ %s\n' "$*"
    [ "$DRY_RUN" -eq 1 ] || "$@"
}

if [ "$DO_BASE" -eq 1 ]; then
    run sudo pacman -S --needed - < "$HERE/packages/base.txt"
fi

if [ "$DO_DESKTOP" -eq 1 ]; then
    run sudo pacman -S --needed - < "$HERE/packages/desktop.txt"
fi

if [ "$DO_AUR" -eq 1 ]; then
    helper=""
    for candidate in paru yay; do
        if command -v "$candidate" >/dev/null 2>&1; then
            helper="$candidate"
            break
        fi
    done
    if [ -z "$helper" ]; then
        echo "no AUR helper found (install paru or yay, or use the vendored bin/)" >&2
        exit 1
    fi
    run "$helper" -S --needed - < "$HERE/packages/aur.txt"
fi
