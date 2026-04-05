#!/bin/bash

# --- CONFIGURACIÓN ---
# Quitamos la barra final para evitar dobles slashes (//) en las rutas
WALLPAPER_DIR="$HOME/Wallpapers"

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    echo "Error: La carpeta $WALLPAPER_DIR no existe."
    exit 1
fi

list_wallpapers() {
    # Usamos fd si lo tienes instalado (es más rápido), sino find está perfecto.
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read -r file; do
        filename=$(basename "$file")
        echo -en "$filename\0icon\x1f$file\n"
    done
}

# --- SELECCIÓN DE ROFI ---
SELECTED=$(list_wallpapers | rofi -dmenu -i -show-icons -p "Wallpaper" -theme "$HOME/.config/rofi/wallselect/style.rasi")

if [[ -z "$SELECTED" ]]; then
    exit 0
fi

FULL_PATH="$WALLPAPER_DIR/$SELECTED"
echo "Aplicando: $FULL_PATH"

# --- EJECUCIÓN EFICIENTE ---

# 1. Cambiar el fondo en segundo plano (&). 
# Nota: Si 'awww' era un typo, el estándar moderno es 'swww'. 
# He ajustado el 'step' a 90 para que el 'grow' sea un barrido rápido y limpio a 60fps.
awww img "$FULL_PATH" \
    --transition-type grow \
    --transition-pos 0.5,0.5 \
    --transition-step 90 \
    --transition-fps 60 &

# 2. Wallust calcula la paleta (Este proceso SÍ bloquea, necesitamos los colores antes de recargar la UI)
# Usamos -q (quiet) para que no ensucie la salida si lo corres desde terminal
wallust run "$FULL_PATH" -q

# 3. Recarga Concurrente del Ecosistema
# Al envolver esto en { } y ponerle un & al final, recargamos Hyprland, SwayNC, Kitty y Waybar AL MISMO TIEMPO.
# Esto elimina el efecto "escalera" donde primero cambia una cosa y luego otra.
{
    # Recargas ligeras
    swaync-client -rs
    killall -q -SIGUSR1 kitty
    hyprctl reload -q

    # Reinicio de Waybar (lo matamos silenciosamente y lo levantamos separado de la terminal)
    killall -q waybar
    nohup waybar > /dev/null 2>&1 &
} &

exit 0
