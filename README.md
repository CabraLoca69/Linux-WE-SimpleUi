# wallpaper-engine-picker

A terminal UI for [linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine) that lets you browse and apply Wallpaper Engine wallpapers from the command line, with live previews and multi-monitor support.

![selector](assets/monitor-selector.png)
![Wselector](assets/wallpaper-selector.png)

---

## Dependencies

- [Steam](https://store.steampowered.com/) with [Wallpaper Engine](https://store.steampowered.com/app/431960/Wallpaper_Engine/) installed and at least one wallpaper downloaded
- [linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine) — follow their README for installation
- [`fzf`](https://github.com/junegunn/fzf) — fuzzy finder
- [`chafa`](https://hpjansson.org/chafa/) — terminal image previews
- [`jq`](https://jqlang.github.io/jq/) — JSON parsing
- `systemd` (user session)

Install dependencies on Arch:
```bash
paru -S fzf chafa jq
```

On Ubuntu/Debian:
```bash
sudo apt install fzf chafa jq
```

---

## Installation

1. Clone the repository:
```bash
git clone https://github.com/CabraLoca69/Linux-WE-SimpleUi.git
cd Linux-WE-SimpleUi
```

2. Run the installer:
```bash
chmod +x ./install
./install

```

3. Edit the config file to match your setup (see [Configuration](#configuration)):
```bash
$EDITOR ~/.config/wallpaperengine/config
```

---

## Configuration

All settings live in `~/.config/wallpaperengine/config`. Both scripts source this file automatically.

```bash
# ── Monitors ───────────────────────────────────────────────────────────────
# To find your monitor names: hyprctl monitors | grep Monitor
# Or with: xrandr | grep " connected"
MONITORS=(
  "DP-1:Left"
  "DP-3:Right"
  # "DP-2:Center"  # add or remove monitors as needed
)

# ── Wallpaper Engine ───────────────────────────────────────────────────────
# See: https://github.com/Almamu/linux-wallpaperengine/blob/main/README.md
# Or run: linux-wallpaperengine --help
FPS=30
WE_ARGS=(--silent --disable-mouse)

# ── Paths ──────────────────────────────────────────────────────────────────
# Usually found a few directories above your wallpaper_engine install folder:
# */SteamLibrary/steamapps/common/wallpaper_engine/assets
ASSETS=""

# */SteamLibrary/steamapps/workshop/content/431960
WORKSHOP=""

# State files — where the picker saves the current wallpaper to restore on boot
STATE_DIR="$HOME/.config/wallpaperengine"
STATE="$STATE_DIR/last_wallpaper.json"
```

> **Tip:** To find your Steam library path, open Steam → Settings → Storage.

---

## Usage

### Picker

```bash
wallpaper-picker
```

Opens a menu to:
- Apply the same wallpaper across all monitors (span)
- Set a different wallpaper per monitor
- Restart the wallpaper service
- Reset a failed systemd service

While browsing wallpapers, a live preview renders in the right panel using `chafa`.

### Restore on login

To restore your last wallpaper automatically when you log in, add this to your Hyprland config (or your compositor's equivalent):

```ini
exec-once = ~/.local/bin/wallpaper-on-start
```

---

## How it works

The picker saves the current wallpaper selection to `~/.config/wallpaperengine/last_wallpaper.json` and runs `linux-wallpaperengine` as a systemd user service. On login, `wallpaper-on-start` reads that file and restores the wallpaper.

---

## Credits

- [linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine) by Almamu — without this none of it works
- [Wallpaper Engine](https://store.steampowered.com/app/431960/Wallpaper_Engine/) by Kristjan Skutta

---

## License

MIT
