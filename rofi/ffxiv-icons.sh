#!/usr/bin/env bash
# ── FFXIV Custom Icon Launcher ──────────────────────────────
# Scans ~/.config/eww/icons/*.png and builds a Rofi dmenu
# with your own PNG icons shown next to each app name.
#
# Icon naming: firefox.png, kitty.png, discord.png etc.
# (exact lowercase match to .desktop app name)
#
# Usage: bind this script to Super+Space instead of plain rofi

ICONS_DIR="$HOME/.config/eww/icons"
ROFI_THEME="$HOME/.config/rofi/ffxiv.rasi"

# If we have custom icons, use icon-theme override
if [[ -d "$ICONS_DIR" ]] && ls "$ICONS_DIR"/*.png &>/dev/null; then
    # Create a temp icon theme that points to our PNGs
    THEME_DIR="$HOME/.local/share/icons/ffxiv-icons"
    mkdir -p "$THEME_DIR/48x48/apps"

    # Symlink all our PNG icons into the theme
    for f in "$ICONS_DIR"/*.png; do
        name=$(basename "$f")
        ln -sf "$f" "$THEME_DIR/48x48/apps/$name" 2>/dev/null
    done

    # Write index.theme if missing
    if [[ ! -f "$THEME_DIR/index.theme" ]]; then
        cat > "$THEME_DIR/index.theme" << 'THEME'
[Icon Theme]
Name=ffxiv-icons
Comment=FFXIV Custom Desktop Icons
Directories=48x48/apps

[48x48/apps]
Size=48
Context=Applications
Type=Fixed
THEME
    fi

    gtk-update-icon-cache "$THEME_DIR" 2>/dev/null

    rofi -show drun \
         -theme "$ROFI_THEME" \
         -icon-theme "ffxiv-icons,Papirus-Dark" \
         -show-icons
else
    rofi -show drun \
         -theme "$ROFI_THEME" \
         -icon-theme "Papirus-Dark" \
         -show-icons
fi
