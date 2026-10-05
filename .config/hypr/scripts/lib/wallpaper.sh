# Shared wallpaper helpers — source this file, do not execute it directly.
# Used by: set_wallpaper, wallpaper_select, wallpaper_auto, restore_wallpaper

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "This file is a library; source it from another script." >&2
    exit 1
fi

# ---------- paths & constants (override via environment if needed) ----------
WP_DIR="${WP_DIR:-$HOME/Pictures/wallpapers}"
WP_CACHE_FILE="${WP_CACHE_FILE:-$HOME/.cache/last_wallpaper.path}"
WP_CACHE_DIR="${WP_CACHE_DIR:-$HOME/.cache/wallpapers}"
WP_PIDFILE="${WP_PIDFILE:-$HOME/.cache/wallpaper_auto.pid}"
WP_SET_SCRIPT="${WP_SET_SCRIPT:-$HOME/.config/hypr/scripts/set_wallpaper}"
WP_AUTO_SCRIPT="${WP_AUTO_SCRIPT:-$HOME/.config/hypr/scripts/wallpaper_auto}"
WP_SELECT_SCRIPT="${WP_SELECT_SCRIPT:-$HOME/.config/hypr/scripts/wallpaper_select}"
WP_ROFI_THEME="${WP_ROFI_THEME:-$HOME/.config/rofi/wallpaper.rasi}"

# 1 = composite over a blurred, zoomed backdrop (only used with fit/center);
# 0 = plain image only (zoomed fill needs no backdrop).
_WP_MODE_FROM_ENV="${WP_MODE:-}"
_WP_BLUR_FROM_ENV="${WP_BLUR:-}"

# How the wallpaper is painted. `fill` = zoom-crop to cover the screen;
# `fit` = show whole image over a blurred, zoomed backdrop.
# Others: stretch | center | tile.
WP_MODE="${WP_MODE:-fill}"
WP_BLUR="${WP_BLUR:-0}"

# Persisted choice so restore/auto/rofi survive reboots.
WP_STATE_FILE="${WP_STATE_FILE:-$HOME/.cache/wallpaper.opts}"

# Load saved mode/blur unless the caller already exported them.
wp_load_state() {
    [ -n "${_WP_MODE_FROM_ENV:-}" ] && [ -n "${_WP_BLUR_FROM_ENV:-}" ] && return 0
    [ -f "$WP_STATE_FILE" ] || return 0
    local saved_mode="" saved_blur=""
    while IFS='=' read -r key val; do
        case "$key" in
            WP_MODE) saved_mode="$val" ;;
            WP_BLUR) saved_blur="$val" ;;
        esac
    done < "$WP_STATE_FILE"
    [ -z "${_WP_MODE_FROM_ENV:-}" ] && [ -n "$saved_mode" ] && WP_MODE="$saved_mode"
    [ -z "${_WP_BLUR_FROM_ENV:-}" ] && [ -n "$saved_blur" ] && WP_BLUR="$saved_blur"
}

# Validate + remember the choice for future runs.
wp_save_state() {
    case "$WP_MODE" in
        stretch|fill|fit|center|tile) ;;
        *) WP_MODE="fill" ;;
    esac
    case "$WP_BLUR" in
        0|1) ;;
        *) WP_BLUR="0" ;;
    esac
    mkdir -p "$(dirname "$WP_STATE_FILE")"
    printf 'WP_MODE=%s\nWP_BLUR=%s\n' "$WP_MODE" "$WP_BLUR" > "$WP_STATE_FILE"
}

# Presets for the common cases.
wp_use_fill() { WP_MODE="fill"; WP_BLUR="0"; wp_save_state; }  # zoomed, no blur
wp_use_fit()  { WP_MODE="fit";  WP_BLUR="1"; wp_save_state; }  # whole image + blurred backdrop

wp_load_state

# ---------- wallpaper discovery ----------
# Prints absolute wallpaper paths, NUL-delimited.
wp_list() {
    find "$WP_DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
           -o -iname '*.gif' -o -iname '*.webp' \) \
        -not -path '*/.git/*' -print0
}

# True when the file is animation-capable and should be painted by mpvpaper.
wp_is_animated() {
    case "${1,,}" in
        *.gif|*.webp|*.mp4|*.webm|*.mov) return 0 ;;
        *) return 1 ;;
    esac
}

# ---------- persistence & notification ----------
# Remember the wallpaper so restore_wallpaper survives reboots.
wp_persist() {
    local rp
    rp=$(realpath "$1" 2>/dev/null || echo "$1")
    printf '%s\n' "$rp" > "$WP_CACHE_FILE"
}

# Reload waybar's wallpaper-aware state and show a toast.
wp_notify_changed() {
    killall -SIGUSR2 waybar 2>/dev/null
    notify-send -t 1000 'Wallpaper changed' "$(basename "$1")"
}

# Set a wallpaper and, only on success, persist + announce it.
wp_apply() {
    "$WP_SET_SCRIPT" --mode "$WP_MODE" "$([ "$WP_BLUR" = "1" ] && echo --blur || echo --no-blur)" "$1" >/dev/null 2>&1 || return 1
    wp_persist "$1"
    wp_notify_changed "$1"
}

# Path of the currently displayed wallpaper, if known.
wp_current() {
    [ -f "$WP_CACHE_FILE" ] || return 1
    tr -d '\r\n' < "$WP_CACHE_FILE"
}

# Re-apply the current wallpaper with the (possibly just changed) mode/blur.
wp_reapply() {
    local cur
    cur=$(wp_current) || { notify-send -t 2000 "Wallpaper" "No current wallpaper to restyle"; return 1; }
    [ -f "$cur" ] || { notify-send -t 2000 "Wallpaper" "Current wallpaper file is gone"; return 1; }
    wp_apply "$cur"
}

# ---------- auto-rotation helpers ----------
# Parse "5s" / "5m" / "5h" / plain minutes into seconds.
wp_parse_interval() {
    local val="$1"
    local num unit
    if [[ "$val" =~ ^([0-9]+)([smh])?$ ]]; then
        num="${BASH_REMATCH[1]}"
        unit="${BASH_REMATCH[2]}"
        case "$unit" in
            s)      echo "$num" ;;
            h)      echo $((num * 3600)) ;;
            m | '') echo $((num * 60)) ;;
        esac
    else
        echo 300
    fi
}

# Stop a running rotation (best effort).
wp_auto_stop() {
    if [ -f "$WP_PIDFILE" ]; then
        local pid
        pid=$(cat "$WP_PIDFILE")
        pkill -P "$pid" 2>/dev/null
        kill "$pid" 2>/dev/null
        rm -f "$WP_PIDFILE"
        notify-send -t 1000 'Auto wallpaper rotation stopped'
    fi
}
