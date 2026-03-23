# dotfiles

My personal Hyprland desktop configuration for Arch Linux, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## 📸 Overview

A modular, dynamic-theming setup built around **Hyprland** (Wayland compositor). Colors are generated automatically from the current wallpaper using **Wallust**, propagating a consistent palette across the bar, terminal, launcher, and notification center.

## 🧩 Components

| Module | Tool | Description |
|---|---|---|
| `hypr` | [Hyprland](https://hyprland.org/) | Wayland compositor — window management, animations, keybinds |
| `waybar` | [Waybar](https://github.com/Alexays/Waybar) | Status bar with workspaces, clock, battery, network, volume |
| `kitty` | [Kitty](https://sw.kovidgoyal.net/kitty/) | GPU-accelerated terminal emulator |
| `rofi` | [Rofi](https://github.com/davatorium/rofi) | App launcher with custom menus (WiFi, wallpapers, music, screenshots) |
| `swaync` | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) | Notification center with a custom CSS style |
| `wallust` | [Wallust](https://codeberg.org/explosion-mental/wallust) | Generates color schemes from wallpapers for all apps |

### Rofi Custom Menus

- **Wallpaper selector** — browse and apply wallpapers via `swww`
- **WiFi manager** — connect to networks without leaving the keyboard
- **Music player** — control Spotify / playerctl
- **Screenshot** — capture regions or full screen via `hyprshot`

## 🛠 Dependencies

### Official repositories (pacman)

```
git stow hyprland waybar rofi kitty
networkmanager bluez bluez-utils
ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd ttf-font-awesome
firefox dolphin
```

### AUR packages

```
swaync wallust-bin swww hyprshot
hyprlock hypridle
swayosd swappy playerctl
xwaylandvideobridge polkit-gnome
```

## 📦 Installation

> **Prerequisites:** Arch Linux with an AUR helper (`yay` or `paru`) and GNU Stow installed.

1. **Clone the repository** into your home directory:

   ```bash
   git clone https://github.com/cRolandoJr/dotfiles.git ~/dotfiles
   ```

2. **Install dependencies** (official repos):

   ```bash
   sudo pacman -Syu --needed git stow hyprland waybar rofi kitty \
     networkmanager bluez bluez-utils \
     ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd ttf-font-awesome \
     firefox dolphin
   ```

3. **Install AUR packages**:

   ```bash
   yay -S --needed swaync wallust-bin swww hyprshot \
     hyprlock hypridle swayosd swappy playerctl \
     xwaylandvideobridge polkit-gnome
   ```

4. **Deploy dotfiles** with GNU Stow:

   ```bash
   cd ~/dotfiles
   stow hypr waybar swaync rofi wallust kitty
   ```

   Or use the provided script which does all of the above:

   ```bash
   bash ~/dotfiles/install.sh
   ```

5. **Log out and select Hyprland** as your session.

## ⌨️ Key Bindings

All bindings use `SUPER` (`$mainMod`) as the modifier key.

### Applications

| Shortcut | Action |
|---|---|
| `SUPER + Return` | Open terminal (Kitty) |
| `SUPER + SHIFT + Return` | Open floating terminal |
| `SUPER + B` | Open browser (Firefox) |
| `SUPER + E` | Open file manager (Dolphin) |
| `SUPER + M` | Open music (Spotify) |
| `SUPER + T` | Open Telegram |
| `SUPER + Space` | App launcher (Rofi) |
| `SUPER + TAB` | Window switcher (Rofi) |
| `SUPER + W` | Wallpaper selector |
| `SUPER + A` | WiFi manager |
| `SUPER + N` | Toggle notification panel |
| `SUPER + L` | Lock screen (Hyprlock) |

### Window Management

| Shortcut | Action |
|---|---|
| `SUPER + Q` | Close active window |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + V` | Toggle floating |
| `SUPER + P` | Pseudo-tiling (dwindle) |
| `SUPER + J` | Toggle split |
| `SUPER + D` | Float / center window |
| `SUPER + R` | Enter resize mode (arrow keys to resize, `Esc` to exit) |

### Workspaces

| Shortcut | Action |
|---|---|
| `SUPER + 1–0` | Switch to workspace 1–10 |
| `SUPER + SHIFT + 1–0` | Move window to workspace 1–10 |
| `SUPER + SHIFT + S` | Send window to scratchpad |
| `SUPER + S` | Toggle scratchpad |
| `SUPER + Scroll` | Cycle workspaces |

### Screenshots

| Shortcut | Action |
|---|---|
| `Print` | Capture full screen to clipboard |
| `SUPER + SHIFT + C` | Capture region to clipboard |
| `SUPER + CTRL + C` | Capture region → edit in Swappy |

### Media & Hardware

| Shortcut | Action |
|---|---|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Toggle mute |
| `XF86MonBrightnessUp/Down` | Adjust brightness |
| Media keys | Play/pause, next, previous |

## 🎨 Dynamic Theming

[Wallust](https://codeberg.org/explosion-mental/wallust) generates a color palette from the active wallpaper and writes color files to `~/.cache/wallust/`. These are then sourced by:

- **Hyprland** — active/inactive border gradients
- **Waybar** — bar color scheme
- **Kitty** — terminal colors
- **Rofi** — launcher colors

To apply a new wallpaper and regenerate colors:

```bash
wallust run /path/to/wallpaper.jpg
```

## 📁 Repository Structure

Each top-level directory is a **GNU Stow package**. Running `stow <package>` from `~/dotfiles` creates symlinks in `~` that mirror the directory tree inside the package. For example, `hypr/.config/hypr/` becomes `~/.config/hypr/`.

```
dotfiles/
├── hypr/        # Hyprland, Hyprlock, Hypridle, Hyprpaper configs
│   └── .config/hypr/          →  ~/.config/hypr/
│       ├── hyprland.conf       # Main entry point (sources sub-configs)
│       ├── configs/
│       │   ├── autostart.conf
│       │   ├── binds.conf
│       │   ├── environments.conf
│       │   ├── monitors.conf
│       │   ├── rules.conf
│       │   └── settings.conf
│       └── scripts/
├── waybar/      # Status bar config and styles
│   └── .config/waybar/        →  ~/.config/waybar/
├── kitty/       # Terminal config
│   └── .config/kitty/         →  ~/.config/kitty/
├── rofi/        # Launcher + custom menus (wifi, wallpaper, music, screenshot)
│   └── .config/rofi/          →  ~/.config/rofi/
├── swaync/      # Notification center config and CSS
│   └── .config/swaync/        →  ~/.config/swaync/
├── wallust/     # Color template definitions
│   └── .config/wallust/       →  ~/.config/wallust/
└── install.sh   # Automated setup script
```
