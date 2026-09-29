#!/usr/bin/env bash
# ── FFXIV Animated Wallpaper Launcher ───────────────────────
# Supports: .mp4, .gif, .webm, .mkv, .png, .jpg
# Put your files in ~/.config/hypr/wallpapers/
#
# Priority: mp4 > gif > webm > static image

WALL_DIR="$HOME/.config/hypr/wallpapers"

# Kill any existing wallpaper process
pkill -x mpvpaper 2>/dev/null
pkill -x swww 2>/dev/null
sleep 0.3

# Detect best available file
find_wall() {
    local ext
    for ext in mp4 webm mkv gif; do
        local f
        f=$(find "$WALL_DIR" -maxdepth 1 -name "*.$ext" 2>/dev/null | head -1)
        [[ -n "$f" ]] && echo "$f" && return
    done
    # Static fallback
    find "$WALL_DIR" -maxdepth 1 \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) \
        2>/dev/null | head -1
}

WALLPAPER=$(find_wall)

if [[ -z "$WALLPAPER" ]]; then
    echo "[wallpaper] No wallpaper found in $WALL_DIR" >&2
    exit 1
fi

echo "[wallpaper] Using: $WALLPAPER"
EXT="${WALLPAPER##*.}"

case "$EXT" in
    mp4|webm|mkv)
        # mpvpaper: plays video as wallpaper on Wayland
        # Install: sudo dnf install mpvpaper  OR  yay -S mpvpaper
        if command -v mpvpaper &>/dev/null; then
            mpvpaper -o "no-audio loop" '*' "$WALLPAPER" &
        else
            echo "[wallpaper] mpvpaper not found — falling back to swww"
            swww-daemon 2>/dev/null &
            sleep 0.5
            swww img "$WALLPAPER" --transition-type wipe --transition-duration 2
        fi
        ;;
    gif)
        # swww handles animated GIFs natively
        swww-daemon 2>/dev/null &
        sleep 0.5
        swww img "$WALLPAPER" \
            --transition-type wipe \
            --transition-duration 2 \
            --transition-fps 60
        ;;
    png|jpg|jpeg)
        swww-daemon 2>/dev/null &
        sleep 0.5
        swww img "$WALLPAPER" \
            --transition-type fade \
            --transition-duration 3
        ;;
esac
