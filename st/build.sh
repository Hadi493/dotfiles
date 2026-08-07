#!/usr/bin/env bash
#
# Build suckless st from source with the alpha (background opacity) patch and a
# configuration that matches the kitty + Hyprland theme (gruber-darker-ayu).
#
# Requirements: git, make, cc, X11/Xft/fontconfig dev headers, tic (ncurses).
# Install location: $HOME/.local/bin/st (+ terminfo es `$HOME/.terminfo`).

set -euo pipefail

ST_TAG="0.8.5"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${ST_BUILD_DIR:-/tmp/st-build}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local}"

ALPHA_PATCH="$SRC_DIR/st-alpha-0.8.5.diff"
THEME_CONFIG="$SRC_DIR/config.h"

deps_ok() {
	command -v make >/dev/null &&
	command -v pkg-config >/dev/null &&
	ls /usr/include/X11/Xft/Xft.h >/dev/null 2>&1 &&
	ls /usr/include/fontconfig/fontconfig.h >/dev/null 2>&1
}

if ! deps_ok; then
	echo "error: missing build dependencies (make, pkg-config, X11/Xft, fontconfig)" >&2
	exit 1
fi

rm -rf "$BUILD_DIR"
git clone --quiet --depth 1 --branch "$ST_TAG" https://git.suckless.org/st "$BUILD_DIR"

echo "-- applying alpha patch --"
patch -s --directory "$BUILD_DIR" -p1 < "$ALPHA_PATCH"

echo "-- installing custom config.h --"
cp -f "$THEME_CONFIG" "$BUILD_DIR/config.h"
touch "$BUILD_DIR/config.h" # ensure newer than config.def.h so make keeps ours

echo "-- building --"
make --directory "$BUILD_DIR" clean all

echo "-- installing to $INSTALL_DIR --"
mkdir -p "$INSTALL_DIR/bin"
cp -f "$BUILD_DIR/st" "$INSTALL_DIR/bin/st"
chmod 755 "$INSTALL_DIR/bin/st"

# terminfo (installs into $HOME/.terminfo for tic)
tic -sx "$BUILD_DIR/st.info"

echo "== done =="
echo "installed: $INSTALL_DIR/bin/st"
echo "running:   st"
echo "opacity:   default 0.88 or override with st -A 0.x under a compositor"