#!/usr/bin/env bash
# ╔════════════════════════════════════════════════════════════════╗
# ║   Instalación de Hyprland + dotfiles en Arch Linux             ║
# ║   GPU: Intel · Audio: PipeWire · Login: SDDM                   ║
# ║   Todo desde pacman. AUR queda al final como opcional.         ║
# ╚════════════════════════════════════════════════════════════════╝
set -euo pipefail

# --- Helpers -----------------------------------------------------------------
log()  { printf '\n\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\n\033[1;33m!!\033[0m %s\n' "$*"; }
die()  { printf '\n\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

[[ $EUID -ne 0 ]] || die "No corras este script como root. Usa tu usuario normal; pedirá sudo cuando haga falta."
command -v sudo >/dev/null || die "Falta sudo. Instalalo como root: pacman -S sudo"
command -v pacman >/dev/null || die "Esto es para Arch Linux."

# --- 1. Sistema base y actualización ----------------------------------------
log "Actualizando el sistema..."
sudo pacman -Syu --noconfirm

log "Instalando utilidades base..."
sudo pacman -S --needed --noconfirm \
    base-devel git stow curl wget unzip \
    man-db man-pages

# --- 2. Drivers Intel + Wayland ---------------------------------------------
log "Drivers gráficos Intel + librerías Wayland..."
sudo pacman -S --needed --noconfirm \
    mesa vulkan-intel intel-media-driver libva-intel-driver \
    qt5-wayland qt6-wayland \
    xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

# --- 3. Audio (PipeWire) ----------------------------------------------------
log "Audio con PipeWire..."
sudo pacman -S --needed --noconfirm \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
    pavucontrol alsa-utils

# --- 4. Red + Bluetooth -----------------------------------------------------
log "Red y Bluetooth..."
sudo pacman -S --needed --noconfirm \
    networkmanager network-manager-applet \
    bluez bluez-utils blueman

# --- 5. Hyprland + ecosistema (todo en repos oficiales) ---------------------
log "Hyprland y ecosistema..."
sudo pacman -S --needed --noconfirm \
    hyprland hyprlock hypridle hyprpaper hyprpicker \
    waybar mako wlogout \
    rofi-wayland \
    grim slurp wl-clipboard cliphist swappy \
    polkit-gnome \
    brightnessctl playerctl \
    kitty thunar thunar-archive-plugin file-roller \
    yazi \
    firefox \
    nwg-look qt5ct qt6ct

# --- 6. Fuentes e iconos ----------------------------------------------------
log "Fuentes (Nerd Fonts, JetBrains Mono, emojis)..."
sudo pacman -S --needed --noconfirm \
    ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono \
    ttf-font-awesome \
    noto-fonts noto-fonts-cjk noto-fonts-emoji \
    papirus-icon-theme

# --- 7. Display manager (SDDM) ----------------------------------------------
log "SDDM como display manager..."
sudo pacman -S --needed --noconfirm sddm

# --- 8. Extras útiles -------------------------------------------------------
log "Utilidades de consola y QoL..."
sudo pacman -S --needed --noconfirm \
    starship fastfetch \
    fzf ripgrep fd bat eza zoxide \
    htop btop \
    neovim \
    openssh

# --- 9. Servicios -----------------------------------------------------------
log "Habilitando servicios del sistema..."
sudo systemctl enable NetworkManager.service
sudo systemctl enable bluetooth.service
sudo systemctl enable sddm.service

# --- 10. Clonar dotfiles y aplicar con stow ---------------------------------
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/cRolandoJr/dotfiles.git}"

if [[ ! -d "$DOTFILES_DIR" ]]; then
    log "Clonando dotfiles en $DOTFILES_DIR ..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    log "$DOTFILES_DIR ya existe, salteando clone."
fi

log "Aplicando dotfiles con stow..."
mkdir -p "$HOME/.config"
cd "$DOTFILES_DIR"
for pkg in hypr waybar kitty rofi mako wlogout starship fastfetch nvim; do
    if [[ -d "$pkg" ]]; then
        stow --restow --target="$HOME" "$pkg" && echo "   ✓ $pkg"
    fi
done

# --- 11. Avisos finales -----------------------------------------------------
cat <<'EOF'

╔════════════════════════════════════════════════════════════════╗
║                       INSTALACIÓN BASE LISTA                   ║
╚════════════════════════════════════════════════════════════════╝

Lo que falta (paquetes del AUR que tu setup usa, pero no están en
los repos oficiales). Cuando quieras tenerlos, instala un helper
del AUR (yay) y después los paquetes.

  # Instalar yay desde fuente (solo pacman + git, sin AUR helper):
  sudo pacman -S --needed git base-devel
  git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
  cd /tmp/yay-bin && makepkg -si

  # Una vez con yay:
  yay -S --needed \
      swww hyprshot swayosd \
      wallust-bin xwaylandvideobridge \
      spotify-launcher

Notas:
  - 'awww-daemon' en autostart.conf es typo: el real es 'swww-daemon'.
    Si no querés usar swww, comentá esa línea y dejá hyprpaper
    (que ya quedó instalado y configurado en hyprpaper.conf).
  - swayosd es solo para el OSD bonito de volumen/brillo. Si no lo
    instalás, los binds de volumen siguen funcionando (usan wpctl),
    solo no verás la barrita visual.
  - xwaylandvideobridge es para compartir pantalla en Discord/Zoom
    bajo XWayland. Opcional.

Siguiente paso:
  1. Reiniciá:  sudo reboot
  2. En la pantalla de login (SDDM), elegí la sesión "Hyprland".
  3. Tecla SUPER + Return abre la terminal. SUPER + Space el launcher.

EOF
