# ⚔ FFXIV Desktop — Nobara Hyprland

A complete Final Fantasy XIV–themed desktop environment for Nobara Linux on Wayland/Hyprland.

---

## Components

| Component | Tool | Purpose |
|-----------|------|---------|
| Widgets | **EWW** | Limit Break bars, Clocks, Alliance panels, Quest Log, Orchestrion, Gil/Disk |
| Bar | **Waybar** | Bottom bar with workspaces, ET clock, music, disk |
| Launcher | **Rofi** | FFXIV-styled start menu |
| Wallpaper | **Swww** | Animated desktop background |
| Notifications | **Dunst** | FFXIV-styled toast notifications with sounds |
| Login | **SDDM** | Animated starfield login screen |
| Window Manager | **Hyprland** | Gold borders, smooth animations |

---

## Quick Install

```bash
# Clone or extract this folder, then:
chmod +x install.sh
./install.sh
```

The install script:
- Installs missing packages via dnf/pacman
- Copies all configs to `~/.config/`
- Installs the SDDM theme (requires sudo)
- Sets up the Discord monitor as a systemd user service

---

## Manual Setup

### 1. Required packages

```bash
# Nobara / Fedora
sudo dnf install eww waybar rofi dunst hyprland playerctl \
                 python3 jq bc iproute lm_sensors swww

# AUR (if on Arch-based):
# yay -S eww-wayland swww
```

### 2. Fonts

Download and install for the full look:

- **Cinzel** — https://fonts.google.com/specimen/Cinzel  
  (Headers, labels, clock types)
- **JetBrains Mono** — https://www.jetbrains.com/lp/mono/  
  (Clock times, numbers)

```bash
mkdir -p ~/.fonts
# Copy .ttf files there, then:
fc-cache -fv
```

### 3. Wallpaper

Put an animated `.gif` or static image at:
```
~/.config/hypr/wallpapers/eorzea.gif
```

**Recommended sources:**
- [Wallhaven.cc](https://wallhaven.cc) — search "final fantasy xiv"
- [WallpaperEngine Workshop](https://store.steampowered.com/app/431960/) (Linux via weepapp)
- YouTube → download as GIF with `yt-dlp`

### 4. Sounds

Place `.ogg` sound files at:
```
~/.config/eww/sounds/
  chime.ogg         ← General notification
  dm_received.ogg   ← Discord DM alert
```

FFXIV system sounds are in the game files under `game/sound/system/`.
You can also use any .ogg sounds — Freesound.org has good options.

### 5. Discord Presence (Alliance A)

To show friend presence and DM alerts:

1. Go to https://discord.com/developers/applications
2. Create a new application → Bot
3. Under **Privileged Gateway Intents**, enable:
   - **Presence Intent**
   - **Server Members Intent**
4. Copy the bot token
5. Invite the bot to your server (needs `View Members` + `Read Message History`)
6. Save the token:

```bash
echo "YOUR_TOKEN_HERE" > ~/.config/eww/data/discord_token
chmod 600 ~/.config/eww/data/discord_token
```

The Discord monitor daemon starts automatically via systemd.

### 6. Quest Log (Todo)

Edit `~/.config/eww/data/quests.json`:

```json
[
  {"text": "Reply to Alex's email", "status": "urgent", "icon": "⚔"},
  {"text": "Update packages",       "status": "active", "icon": "◈"},
  {"text": "Done task",             "status": "done",   "icon": "◈"}
]
```

**Status values:** `urgent` (orange), `active` (normal), `done` (strikethrough)

Click any quest in the widget to toggle done/active.

Add quests from terminal:
```bash
# add_quest.sh helper (simple append)
python3 -c "
import json, sys
f = open('$HOME/.config/eww/data/quests.json')
q = json.load(f); f.close()
q.append({'text': sys.argv[1], 'status': 'active', 'icon': '◈'})
open('$HOME/.config/eww/data/quests.json','w').write(json.dumps(q,indent=2))
" "Your new quest text here"
```

Or integrate with **Taskwarrior**: `task export` outputs JSON you can pipe in.

### 7. GPU Support

**NVIDIA:**
```bash
sudo dnf install nvidia-smi  # usually comes with driver
```

**AMD:**
```bash
sudo dnf install radeontop
# or use sysfs (automatic fallback in gpu_usage.sh / gpu_temp.sh)
```

### 8. SDDM Login Theme

Already installed by `install.sh`. To activate manually:
```bash
sudo mkdir -p /usr/share/sddm/themes/ffxiv-login
sudo cp -r sddm/ffxiv-theme/* /usr/share/sddm/themes/ffxiv-login/

sudo tee /etc/sddm.conf.d/ffxiv-theme.conf << 'EOF'
[Theme]
Current=ffxiv-login
EOF

sudo systemctl restart sddm
```

---

## EWW Widget Controls

| Shortcut | Action |
|----------|--------|
| `Super + L` | Toggle Quest Log |
| Click quest item | Toggle done/active |
| Click Alliance A member | Focus Discord |
| Click Alliance B window | Focus that app |
| Scroll music widget | Next/prev track |

---

## Hyprland Keybinds

| Key | Action |
|-----|--------|
| `Super + Enter` | Terminal (kitty) |
| `Super + Space` | App launcher (Rofi FFXIV menu) |
| `Super + Q` | Close window |
| `Super + F` | Fullscreen |
| `Super + T` | Toggle float |
| `Super + E` | File manager |
| `Super + 1-8` | Switch workspace |
| `Super + Shift + 1-8` | Move window to workspace |
| `Print` | Screenshot (output) |
| `Super + Print` | Screenshot (window) |
| `Shift + Print` | Screenshot (region) |
| `Super + N` | Close notification |
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioNext/Prev` | Next/Prev track |

---

## File Structure

```
~/.config/
├── eww/
│   ├── eww.yuck          # Widget definitions
│   ├── eww.scss          # Styles
│   ├── scripts/
│   │   ├── eorzea_time.py
│   │   ├── cpu_usage.sh
│   │   ├── gpu_usage.sh
│   │   ├── ram_usage.sh
│   │   ├── cpu_temp.sh
│   │   ├── gpu_temp.sh
│   │   ├── net_speed.sh
│   │   ├── music_progress.sh
│   │   ├── active_windows.sh
│   │   ├── toggle_quest.py
│   │   ├── discord_monitor.py
│   │   └── open_discord.sh
│   ├── data/
│   │   ├── quests.json
│   │   ├── discord_friends.json
│   │   ├── discord_dms.json
│   │   └── discord_token      ← chmod 600!
│   └── sounds/
│       ├── chime.ogg
│       └── dm_received.ogg
├── waybar/
│   ├── config.jsonc
│   └── style.css
├── hypr/
│   ├── hyprland.conf
│   └── wallpapers/
│       └── eorzea.gif
├── dunst/
│   └── dunstrc
└── rofi/
    └── ffxiv.rasi
```

---

## Troubleshooting

**EWW widgets don't show:**
```bash
eww kill && eww daemon
eww open-many limit_break_win clock_win party_win quest_win music_win gil_win
eww logs  # check for errors
```

**GPU temp shows —:**
Run `sensors-detect` to configure lm-sensors, then `sensors` to verify output labels. Edit `cpu_temp.sh`/`gpu_temp.sh` to match your sensor names.

**Music not updating:**
```bash
playerctl status        # should show Playing/Paused
playerctl metadata title
```
If empty, ensure your player (Audacious/Spotify) supports MPRIS2.
In Audacious: Preferences → Plugins → enable "MPRIS2 Server".

**Eorzea time wrong:**
Python 3 must be in PATH. Test with: `python3 ~/.config/eww/scripts/eorzea_time.py`

**Discord friends all offline:**
Check the bot token file exists and the bot has the Presence/Members intents enabled.
View daemon logs: `journalctl --user -u ffxiv-discord -f`
