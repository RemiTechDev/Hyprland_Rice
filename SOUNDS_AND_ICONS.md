# 🎵 Sounds · 🎬 Animations · 🖼 Icons — Setup Guide

## Sounds (.mp3)

Place your MP3 files in: `~/.config/eww/sounds/`

| Filename | Plays when |
|----------|-----------|
| `chime.mp3` | Any desktop notification |
| `dm_received.mp3` | Discord DM received (Alliance A glow) |
| `login.mp3` | SDDM login screen loads |
| `quest_complete.mp3` | Quest marked as done |
| `menu_open.mp3` | Rofi launcher opens |
| `level_up.mp3` | Optional — assign to any keybind |
| `error.mp3` | System error notification |

**Any other MP3 filenames?** Edit the `SOUND_MAP` in `~/.config/eww/scripts/play_sound.sh`.

All sounds are played through `mpv --no-terminal` which supports:
`.mp3` `.ogg` `.wav` `.flac` `.aac` `.m4a`

---

## Animated Wallpaper (.mp4)

Place ONE video file in: `~/.config/hypr/wallpapers/`

```
~/.config/hypr/wallpapers/
  eorzea.mp4        ← your animation (preferred)
  eorzea.gif        ← fallback if no mp4
  eorzea.png        ← static fallback
```

The wallpaper script (`hyprland-wallpaper.sh`) auto-detects the best format:
- **MP4/WebM** → played via `mpvpaper` (install: `sudo dnf install mpvpaper`)
- **GIF** → played via `swww` (already in Nobara)
- **PNG/JPG** → displayed via `swww` with fade transition

**mpvpaper install:**
```bash
# Fedora/Nobara:
sudo dnf install mpvpaper

# Arch:
yay -S mpvpaper

# From source if unavailable:
git clone https://github.com/GhostNaN/mpvpaper
cd mpvpaper && meson build && ninja -C build && sudo ninja -C build install
```

### SDDM Login Animation

Place your login screen video at:
```
/usr/share/sddm/themes/ffxiv-login/background.mp4
```
Also put a static fallback:
```
/usr/share/sddm/themes/ffxiv-login/background.png
```
And login sound:
```
/usr/share/sddm/themes/ffxiv-login/login.mp3
```

---

## Icons (.png)

### Custom App Icons (Alliance B + Rofi menu)

Place your PNG icons in: `~/.config/eww/icons/`

Naming: **exact lowercase app class name** + `.png`

```
~/.config/eww/icons/
  firefox.png
  kitty.png
  discord.png
  spotify.png
  code.png
  steam.png
  thunar.png
  audacious.png
  ...
```

To find an app's class name:
```bash
hyprctl clients | grep "class:"
# or hover over a window and run:
hyprctl activewindow | grep class
```

Icons are shown in Alliance B (running apps) and in the Rofi launcher.
Recommended size: **48×48px** or **64×64px** PNG with transparency.

### SDDM Logo

Place your logo PNG at:
```
/usr/share/sddm/themes/ffxiv-login/logo.png
```
Shown above the login form. Recommended: **128×128px** with transparency.

### Where to get FFXIV-style icons

- [game-icons.net](https://game-icons.net) — free SVG/PNG, export in gold colour
- [Papirus icon theme](https://github.com/PapirusDevelopmentTeam/papirus-icon-pack) — high quality, can recolour with papirus-folders
- Extract directly from FFXIV game files using `TexTools` (Windows) then copy PNGs over
- Commission or create in Inkscape — use hex `#c8a840` for gold fills

---

## Quick file placement summary

```
~/.config/
└── eww/
    ├── icons/           ← your .png app icons (48px recommended)
    │   ├── firefox.png
    │   ├── discord.png
    │   └── ...
    └── sounds/          ← your .mp3 sound files
        ├── chime.mp3
        ├── dm_received.mp3
        ├── login.mp3
        └── ...

~/.config/hypr/
└── wallpapers/
    └── eorzea.mp4       ← your desktop animation

/usr/share/sddm/themes/ffxiv-login/
├── background.mp4       ← login screen animation
├── login.mp3            ← login screen sound
└── logo.png             ← optional logo above login form
```
