# dotfiles
Configuración personal de **Hyprland** para Arch Linux, gestionada con [GNU Stow](https://www.gnu.org/software/stow/). También probado en NixOS (los configs son los mismos; sólo cambia cómo se instalan los paquetes).

## 🧩 Componentes
| Módulo | Herramienta | Descripción |
|---|---|---|
| `hypr` | [Hyprland](https://hyprland.org/) | Compositor Wayland — ventanas, animaciones, atajos |
| `waybar` | [Waybar](https://github.com/Alexays/Waybar) | Barra de estado (workspaces, reloj, batería, red, volumen, layout) |
| `kitty` | [Kitty](https://sw.kovidgoyal.net/kitty/) | Terminal acelerada por GPU |
| `rofi` | [Rofi](https://github.com/davatorium/rofi) | Launcher + menús de WiFi, wallpapers, música y capturas |
| `mako` | [Mako](https://github.com/emersion/mako) | Daemon de notificaciones para Wayland |
| `wlogout` | [wlogout](https://github.com/ArtsyMacaw/wlogout) | Menú de cierre de sesión / apagado |
| `starship` | [Starship](https://starship.rs/) | Prompt de shell multiplataforma |
| `fastfetch` | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) | Info del sistema al abrir terminal |
| `nvim` | [Neovim](https://neovim.io/) | Editor |

## 📦 Instalación

Los configs en `~/.config/*` son agnósticos: la diferencia entre Arch y NixOS está en cómo se instalan los paquetes y se habilitan los servicios.

---

### 🟦 Arch Linux

**Opción A — script automatizado (recomendado)**

Todo desde `pacman` (sin AUR helper requerido). Drivers Intel, PipeWire, SDDM y los dotfiles aplicados con `stow`:
```bash
git clone https://github.com/cRolandoJr/dotfiles.git ~/dotfiles
bash ~/dotfiles/install-arch.sh
```
Lo que hace:
- Actualiza el sistema y resuelve dependencias con `--needed`.
- Instala drivers Intel (`mesa`, `vulkan-intel`, `intel-media-driver`).
- Instala PipeWire (audio), NetworkManager + Bluetooth, y el stack completo de Hyprland (`hyprland`, `hyprlock`, `hypridle`, `hyprpaper`, `waybar`, `mako`, `wlogout`, `rofi-wayland`, `kitty`, `thunar`, `yazi`, `firefox`, etc.).
- Fuentes Nerd / Font Awesome / Noto + emoji.
- Habilita servicios: `NetworkManager`, `bluetooth`, `sddm`.
- Aplica los configs con `stow` para cada módulo.
- Imprime instrucciones para instalar los extras del AUR si los querés (`swww`, `hyprshot`, `swayosd`, `wallust-bin`, `xwaylandvideobridge`).

Variables opcionales:
```bash
DOTFILES_DIR=~/mis-dotfiles DOTFILES_REPO=https://… bash install-arch.sh
```

**Opción B — manual**

```bash
sudo pacman -S --needed git stow \
  hyprland hyprlock hypridle hyprpaper waybar mako wlogout rofi-wayland \
  kitty thunar yazi firefox \
  grim slurp wl-clipboard cliphist swappy playerctl brightnessctl \
  polkit-gnome xdg-desktop-portal-hyprland \
  pipewire pipewire-pulse wireplumber pavucontrol \
  networkmanager network-manager-applet bluez bluez-utils blueman \
  sddm starship fastfetch neovim \
  ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-font-awesome noto-fonts-emoji
sudo systemctl enable --now NetworkManager bluetooth sddm
cd ~/dotfiles && for p in hypr waybar kitty rofi mako wlogout starship fastfetch nvim; do stow "$p"; done
```

Luego, en SDDM, elegí la sesión **Hyprland**.

---

### ❄️ NixOS

El `install-arch.sh` **no aplica**. En NixOS los paquetes y servicios se declaran en `/etc/nixos/configuration.nix` (o en módulos importados desde ahí), y los dotfiles se enlazan con `stow` igual que en Arch — o se gestionan con [Home Manager](https://nix-community.github.io/home-manager/) si preferís un enfoque 100% declarativo.

**1. Habilitar Hyprland y servicios en `configuration.nix`:**
```nix
{ pkgs, ... }: {
  # Compositor + portales
  programs.hyprland.enable = true;

  # Display manager
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # Audio (PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Red + Bluetooth
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Paquetes del entorno
  environment.systemPackages = with pkgs; [
    # Hyprland stack
    hyprlock hypridle hyprpaper hyprpicker
    waybar mako wlogout rofi-wayland
    grim slurp wl-clipboard cliphist swappy
    polkit_gnome brightnessctl playerctl
    # Apps
    kitty thunar yazi firefox
    # Shell / TUI
    stow starship fastfetch neovim
    fzf ripgrep fd bat eza zoxide htop btop
    # AUR-equivalentes (en nixpkgs sí están)
    swww hyprshot swayosd wallust
  ];

  # Fuentes
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
    font-awesome
    noto-fonts noto-fonts-cjk-sans noto-fonts-emoji
  ];
}
```
Luego: `sudo nixos-rebuild switch`.

**2. Aplicar los dotfiles:**
```bash
git clone https://github.com/cRolandoJr/dotfiles.git ~/dotfiles
nix-shell -p stow --run '
  cd ~/dotfiles
  for p in hypr waybar kitty rofi mako wlogout starship fastfetch nvim; do stow "$p"; done
'
```

**3. Iniciar sesión** y elegir **Hyprland** en SDDM.

> **Nota:** en NixOS muchos de los paquetes que en Arch viven en el AUR (`swww`, `hyprshot`, `swayosd`, `wallust`) están directamente en `nixpkgs`, así que no hace falta nada extra.

## ⌨️ Atajos de teclado (`SUPER` = tecla modificadora)
| Atajo | Acción |
|---|---|
| `SUPER + Return` / `+ SHIFT` | Terminal Kitty · flotante |
| `SUPER + Space` | Launcher (Rofi) |
| `SUPER + B / M / T` | Firefox · Spotify · Telegram |
| `SUPER + E` / `+ SHIFT` | Yazi (kitty flotante) · Thunar |
| `SUPER + W / A / C / L` | Wallpapers · WiFi · Clipboard · Bloquear pantalla |
| `SUPER + Escape` | wlogout (menú de sesión) |
| `SUPER + Q / F / V` | Cerrar · Fullscreen · Flotante |
| `SUPER + P / D` | Pseudo-tiling · Toggle floating+centrar |
| `SUPER + R` | Modo resize (flechas para ajustar, `Esc` para salir) |
| `SUPER + SHIFT + M` | Salir de Hyprland |
| `SUPER + 1–0` / `+ SHIFT` | Cambiar workspace · mover ventana |
| `SUPER + S` / `+ SHIFT + S` | Toggle scratchpad · enviar al scratchpad |
| `SUPER + O` / `+ SHIFT + O` | Toggle scratchpad 2 · enviar |
| `SUPER + ←↑→↓` | Mover foco |
| `SUPER + Scroll` | Ciclar workspaces |
| `SUPER + click izq/der` | Mover · redimensionar ventana |
| `Print` | Captura de pantalla completa → portapapeles |
| `SUPER + SHIFT + C` | Recorte de región → portapapeles |
| `SUPER + CTRL + C` | Recorte de región → guardar en `~/.local/share/screenshots` + portapapeles |
| Teclas multimedia | Volumen (PipeWire) · Brillo · Play/Pausa/Siguiente/Anterior |
| `Alt + Shift` | Cambiar layout de teclado (notificación vía script) |

## 📁 Estructura
Cada directorio es un paquete Stow; `stow <paquete>` crea symlinks de `<paquete>/.config/…` → `~/.config/…`.
```
dotfiles/
├── hypr/             # hyprland.conf + configs/{autostart,binds,environments,monitors,rules,settings}.conf + scripts/
├── waybar/           # config.jsonc + style.css
├── kitty/            # kitty.conf
├── rofi/             # config.rasi + menús (wifi, wallselect, musicPlayer, hyprshot)
├── mako/             # config
├── wlogout/          # layout + style.css
├── starship/         # starship.toml
├── fastfetch/        # config.jsonc
├── nvim/             # init.lua + lua/
├── install-arch.sh   # instalador automático para Arch
└── install.sh        # legacy
```
