#!/bin/bash
# ╔════════════════════════════════════════════════╗
# ║        DOTFILES INSTALLATION SCRIPT            ║
# ╚════════════════════════════════════════════════╝

echo "Iniciando la instalación del entorno Hyprland..."

# 1. Actualizar el sistema e instalar paquetes base (requiere sudo)
echo "Instalando dependencias desde los repositorios oficiales..."
sudo pacman -Syu --needed git stow hyprland waybar rofi kitty networkmanager bluez bluez-utils ttf-nerd-fonts-symbols ttf-jetbrains-mono-nerd ttf-font-awesome firefox dolphin

# (Opcional) Instalar paquetes del AUR si usas 'yay' o 'paru'
# echo "Instalando paquetes del AUR..."
# yay -S --needed swaync wallust-bin swww hyprshot

# 2. Desplegar los dotfiles con GNU Stow
echo "Creando enlaces simbólicos con Stow..."
cd ~/dotfiles
stow hypr
stow waybar
stow swaync
stow rofi
stow wallust
stow kitty

# 3. Aplicar "Fixes" del sistema (La magia SysAdmin)
echo "Aplicando parches del sistema..."
# Enmascarar el notificador de crashes de KDE para evitar errores visuales en Hyprland
systemctl --user stop drkonqi-coredump-launcher.service 2>/dev/null
systemctl --user mask drkonqi-coredump-launcher.service
systemctl --user mask drkonqi-coredump-launcher.socket

echo "¡Instalación completada! Por favor, reinicia tu sesión."
