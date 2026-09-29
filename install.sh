#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  FFXIV Desktop — Install Script
#  Run from the ffxiv-desktop/ directory:
#      chmod +x install.sh && ./install.sh
# ══════════════════════════════════════════════════════════════

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$HOME/.config"

echo ""
echo "  ■ FFXIV Desktop Install"
echo "  ─────────────────────────────────────────────"

# ── Helper ────────────────────────────────────────────────────
install_file() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    cp -v "$src" "$dst"
}

backup() {
    local f="$1"
    [[ -e "$f" && ! -L "$f" ]] && mv "$f" "${f}.bak.$(date +%s)" && \
        echo "  [backup] ${f}"
}

# ── 1. Packages ───────────────────────────────────────────────
echo ""
echo "  [1/8] Checking required packages..."
PKGS=(eww waybar rofi dunst mpvpaper swww hyprland playerctl \
      python3 jq bc iproute2 lm_sensors)
MISSING=()
for p in "${PKGS[@]}"; do
    command -v "$p" &>/dev/null || MISSING+=("$p")
done

if [[ ${#MISSING[@]} -gt 0 ]]; then
    echo "  Installing: ${MISSING[*]}"
    sudo dnf install -y "${MISSING[@]}" 2>/dev/null || \
    sudo pacman -S --noconfirm "${MISSING[@]}" 2>/dev/null || \
    echo "  [warn] Could not auto-install. Install manually: ${MISSING[*]}"
fi

# Optional: discord.py for presence monitor
python3 -c "import discord" 2>/dev/null || \
    pip3 install --user discord.py 2>/dev/null && \
    echo "  discord.py installed"

# ── 2. EWW ────────────────────────────────────────────────────
echo ""
echo "  [2/8] Installing EWW config..."
backup "$CFG/eww/eww.yuck"
backup "$CFG/eww/eww.scss"

install_file "$REPO_DIR/eww/eww.yuck"  "$CFG/eww/eww.yuck"
install_file "$REPO_DIR/eww/eww.scss"  "$CFG/eww/eww.scss"

mkdir -p "$CFG/eww/scripts" "$CFG/eww/data"
cp -v "$REPO_DIR/eww/scripts/"* "$CFG/eww/scripts/"
chmod +x "$CFG/eww/scripts/"*

# Copy default data files (don't overwrite existing quests)
[[ ! -f "$CFG/eww/data/quests.json" ]] && \
    install_file "$REPO_DIR/eww/data/quests.json" "$CFG/eww/data/quests.json"

[[ ! -f "$CFG/eww/data/discord_friends.json" ]] && \
    echo '[]' > "$CFG/eww/data/discord_friends.json"

[[ ! -f "$CFG/eww/data/discord_dms.json" ]] && \
    echo '[]' > "$CFG/eww/data/discord_dms.json"

# ── 3. Waybar ─────────────────────────────────────────────────
echo ""
echo "  [3/8] Installing Waybar config..."
backup "$CFG/waybar/config.jsonc"
backup "$CFG/waybar/style.css"
install_file "$REPO_DIR/waybar/config.jsonc" "$CFG/waybar/config.jsonc"
install_file "$REPO_DIR/waybar/style.css"    "$CFG/waybar/style.css"

# ── 4. Hyprland ───────────────────────────────────────────────
echo ""
echo "  [4/8] Installing Hyprland config..."
backup "$CFG/hypr/hyprland.conf"
install_file "$REPO_DIR/hyprland/hyprland.conf" "$CFG/hypr/hyprland.conf"

# ── 5. Dunst ─────────────────────────────────────────────────
echo ""
echo "  [5/8] Installing Dunst config..."
backup "$CFG/dunst/dunstrc"
install_file "$REPO_DIR/hyprland/dunstrc" "$CFG/dunst/dunstrc"

# ── 6. Rofi ──────────────────────────────────────────────────
echo ""
echo "  [6/8] Installing Rofi theme..."
install_file "$REPO_DIR/rofi/ffxiv.rasi" "$CFG/rofi/ffxiv.rasi"

# ── 7. SDDM login theme ───────────────────────────────────────
echo ""
echo "  [7/8] Installing SDDM theme..."
SDDM_THEME_DIR="/usr/share/sddm/themes/ffxiv-login"
if [[ -d "$REPO_DIR/sddm/ffxiv-theme" ]]; then
    sudo mkdir -p "$SDDM_THEME_DIR"
    sudo cp -rv "$REPO_DIR/sddm/ffxiv-theme/"* "$SDDM_THEME_DIR/"

    # Write SDDM config
    sudo mkdir -p /etc/sddm.conf.d
    sudo tee /etc/sddm.conf.d/ffxiv-theme.conf > /dev/null << 'SDDMEOF'
[Theme]
Current=ffxiv-login
SDDMEOF
    echo "  SDDM theme installed. Restart SDDM to apply."
fi

# ── 8. Sounds directory ───────────────────────────────────────
echo ""
echo "  [8/8] Setting up sounds directory..."
SOUNDS="$CFG/eww/sounds"
mkdir -p "$SOUNDS"
if [[ ! -f "$SOUNDS/chime.mp3" ]]; then
    # Copy system sounds as placeholders if present
    SYSTEM_SOUND=$(find /usr/share/sounds -name "*.mp3" 2>/dev/null | head -1)
    if [[ -n "$SYSTEM_SOUND" ]]; then
        cp "$SYSTEM_SOUND" "$SOUNDS/chime.mp3"
        cp "$SYSTEM_SOUND" "$SOUNDS/dm_received.mp3"
        echo "  [sounds] Placeholder sounds copied from system."
    fi
    echo "  [sounds] Place your .mp3 files in: $SOUNDS"
    echo "    chime.mp3       — general notification"
    echo "    dm_received.mp3 — Discord DM alert"
fi

# ── Autostart with systemd user service ───────────────────────
echo ""
echo "  Setting up systemd user service for Discord monitor..."
mkdir -p "$HOME/.config/systemd/user"
cat > "$HOME/.config/systemd/user/ffxiv-discord.service" << 'SYSTEMD'
[Unit]
Description=FFXIV Desktop Discord Presence Monitor
After=graphical-session.target

[Service]
ExecStart=/usr/bin/python3 %h/.config/eww/scripts/discord_monitor.py
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
SYSTEMD

systemctl --user daemon-reload
systemctl --user enable ffxiv-discord.service 2>/dev/null || true

# ── Wallpaper directory ───────────────────────────────────────
echo ""
mkdir -p "$CFG/hypr/wallpapers"
echo "  [wallpaper] Put animated .gif or static image in:"
echo "    $CFG/hypr/wallpapers/eorzea.gif"
echo "  Recommended: search 'FFXIV animated wallpaper' on Wallpaper Engine / wallhaven.cc"

# ── Discord bot token ─────────────────────────────────────────
echo ""
if [[ ! -f "$CFG/eww/data/discord_token" ]]; then
    echo "  [discord] To enable friend presence in Alliance A:"
    echo "    1. Create a bot at https://discord.com/developers/applications"
    echo "    2. Enable Privileged Gateway Intents: Presence Intent + Server Members Intent"
    echo "    3. Add bot to your server"
    echo "    4. Paste the bot token into: $CFG/eww/data/discord_token"
    echo "    5. chmod 600 $CFG/eww/data/discord_token"
fi

# ── Fonts ─────────────────────────────────────────────────────
echo ""
echo "  [fonts] For the full FFXIV aesthetic, install these fonts:"
echo "    Cinzel        — https://fonts.google.com/specimen/Cinzel"
echo "    JetBrains Mono — https://www.jetbrains.com/lp/mono/"
echo "  Then run: fc-cache -fv"

# ── Done ──────────────────────────────────────────────────────
echo ""
echo "  ══════════════════════════════════════════════════"
echo "  ■ Install complete!"
echo ""
echo "  Next steps:"
echo "    1. Add wallpaper to ~/.config/hypr/wallpapers/eorzea.gif"
echo "    2. Add sounds to ~/.config/eww/sounds/"
echo "    3. (Optional) Add Discord bot token"
echo "    4. Log out and back in, or run:"
echo "       hyprctl reload && eww reload"
echo "  ══════════════════════════════════════════════════"
echo ""
