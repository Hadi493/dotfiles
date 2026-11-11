# Shared clipboard thumbnail helpers — source this file, do not execute it
# directly.  Used by: clipboard (picker), clipboard-store (wl-paste --watch).
#
# A thumbnail is a small PNG (128px by default, ~10 KiB) cached by cliphist
# entry id.  It is built once, at store time, so the picker only ever points
# fuzzel at tiny files instead of multi-megabyte originals.

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This file is a library; source it from another script." >&2
    exit 1
fi

CLIP_THUMB_DIR="${CLIP_THUMB_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-thumbs}"
CLIP_THUMB_PX="${CLIP_THUMB_PX:-128}"
mkdir -p "$CLIP_THUMB_DIR"

# clip_ensure_thumb <id>: 0 if the cached thumbnail exists afterwards.
clip_ensure_thumb() {
    local id="$1" out="$CLIP_THUMB_DIR/$1.png" tmp
    [ -s "$out" ] && return 0
    tmp="$CLIP_THUMB_DIR/.tmp-$id.$$"
    if printf '%s' "$id" | cliphist decode 2>/dev/null |
        nice -n 15 magick - -thumbnail "${CLIP_THUMB_PX}x${CLIP_THUMB_PX}>" -strip "png:$tmp" 2>/dev/null &&
        [ -s "$tmp" ]; then
        mv -f "$tmp" "$out"
        return 0
    fi
    rm -f "$tmp"
    return 1
}

# clip_prune_thumbs <id>...: drop thumbnails of entries that no longer exist,
# plus the old full-size .bin cache and stale temp files.
clip_prune_thumbs() {
    local f base id
    declare -A keep=()
    for id in "$@"; do keep["$id"]=1; done
    for f in "$CLIP_THUMB_DIR"/* "$CLIP_THUMB_DIR"/.[!.]*; do
        [ -f "$f" ] || continue
        base=${f##*/}
        case "$base" in
            .tmp-*) [ -z "$(find "$f" -mmin +60 2>/dev/null)" ] || rm -f "$f" ;;
            *.png) [ -n "${keep[${base%.png}]+x}" ] || rm -f "$f" ;;
            *) rm -f "$f" ;; # legacy full-size decode cache
        esac
    done
}
