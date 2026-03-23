# dotfiles
Configuración personal de **Hyprland** para Arch Linux, gestionada con [GNU Stow](https://www.gnu.org/software/stow/). Los colores se generan automáticamente desde el wallpaper activo con **Wallust** y se propagan a la barra, terminal, launcher y notificaciones.

## 🧩 Componentes
| Módulo | Herramienta | Descripción |
|---|---|---|
| `hypr` | [Hyprland](https://hyprland.org/) | Compositor Wayland — ventanas, animaciones, atajos |
| `waybar` | [Waybar](https://github.com/Alexays/Waybar) | Barra de estado (workspaces, reloj, batería, red, volumen) |
| `kitty` | [Kitty](https://sw.kovidgoyal.net/kitty/) | Terminal acelerada por GPU |
| `rofi` | [Rofi](https://github.com/davatorium/rofi) | Launcher + menús de WiFi, wallpapers, música y capturas |
| `swaync` | [SwayNC](https://github.com/ErikReider/SwayNotificationCenter) | Centro de notificaciones |
| `wallust` | [Wallust](https://codeberg.org/explosion-mental/wallust) | Genera paleta de colores desde el wallpaper para todas las apps |

## 📦 Instalación
> Requisitos: Arch Linux, AUR helper (`yay`/`paru`) y GNU Stow.
```bash
git clone https://github.com/cRolandoJr/dotfiles.git ~/dotfiles
sudo pacman -Syu --needed git stow hyprland waybar rofi kitty \
  networkmanager bluez bluez-utils firefox dolphin \
  ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd ttf-font-awesome
yay -S --needed swaync wallust-bin swww hyprshot \
  hyprlock hypridle swayosd swappy playerctl xwaylandvideobridge polkit-gnome
bash ~/dotfiles/install.sh   # clona, instala y hace stow de todo
```
Luego cierra sesión y selecciona **Hyprland**.

## ⌨️ Atajos de teclado (`SUPER` = tecla modificadora)
| Atajo | Acción |
|---|---|
| `SUPER + Return` | Terminal · `+ SHIFT` flotante |
| `SUPER + Space / TAB` | Launcher / Cambiar ventana (Rofi) |
| `SUPER + B / E / M / T` | Firefox · Dolphin · Spotify · Telegram |
| `SUPER + W / A / N / L` | Wallpapers · WiFi · Notificaciones · Bloquear |
| `SUPER + Q / F / V / R` | Cerrar · Pantalla completa · Flotante · Redimensionar |
| `SUPER + P / J / D` | Pseudo-tiling · Toggle split · Flotar/centrar |
| `SUPER + 1–0` | Cambiar workspace · `+ SHIFT` mover ventana |
| `SUPER + S / SHIFT+S` | Toggle scratchpad / Enviar al scratchpad |
| `SUPER + Scroll` | Ciclar workspaces |
| `Print` | Captura completa al portapapeles |
| `SUPER + SHIFT+C / CTRL+C` | Recorte al portapapeles · Recorte + Swappy |
| Teclas multimedia | Volumen · Brillo · Play/Pausa/Siguiente/Anterior |

## 🎨 Theming dinámico
`wallust run /ruta/wallpaper.jpg` genera una paleta y la aplica a Hyprland (bordes), Waybar, Kitty y Rofi via `~/.cache/wallust/`.

## 📁 Estructura
Cada directorio es un paquete Stow; `stow <paquete>` crea symlinks de `<paquete>/.config/…` → `~/.config/…`.
```
dotfiles/
├── hypr/      # hyprland.conf + configs/{autostart,binds,environments,monitors,rules,settings}.conf
├── waybar/    # config.jsonc + style.css
├── kitty/     # kitty.conf
├── rofi/      # config.rasi + menús (wifi, wallselect, musicPlayer, hyprshot)
├── swaync/    # config.json + style.css
├── wallust/   # wallust.toml + templates/
└── install.sh
```
