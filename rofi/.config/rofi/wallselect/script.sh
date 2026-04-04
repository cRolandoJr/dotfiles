#!/bin/bash

# --- CONFIGURACIÓN ---
WALLPAPER_DIR="$HOME/Wallpapers/"
# ---------------------

if [[ ! -d "$WALLPAPER_DIR" ]]; then
    echo "La carpeta $WALLPAPER_DIR no existe."
    exit 1
fi

list_wallpapers() {
    # IMPORTANTE: Seguimos enviando el nombre ($filename) para que el script sepa qué elegir,
    # aunque luego lo ocultemos visualmente.
    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read -r file; do
        filename=$(basename "$file")
        echo -en "$filename\0icon\x1f$file\n"
    done
}

# --- CONFIGURACIÓN DE ROFI ---
# 1. element-text { enabled: false; } -> Esto OCULTA el texto pero mantiene la data.
# 2. children: [ element-icon ]; -> Solo dibujamos el icono.
# 3. background-color: transparent; -> Para que se vea limpio.

SELECTED=$(list_wallpapers | rofi -dmenu -i -show-icons -p "Wallpaper" \
    -theme "$HOME/.config/rofi/wallselect/style.rasi" \
)

if [[ -z "$SELECTED" ]]; then
    exit 0
fi

FULL_PATH="$WALLPAPER_DIR/$SELECTED"

echo "Aplicando: $FULL_PATH"
awww img "$FULL_PATH" --transition-type grow --transition-pos 0.5,0.5 --transition-duration 0.5 --transition-fps 60

FULL_PATH="$WALLPAPER_DIR/$SELECTED"

echo "Aplicando: $FULL_PATH"

# 1. Cambia el fondo con animación
awww img "$FULL_PATH" --transition-type grow --transition-pos 0.5,0.5 --transition-step 90 --transition-fps 60

# 2. NUEVO: Wallust lee la imagen y extrae los colores mágicamente
wallust run "$FULL_PATH"

swaync-client -rs

killall waybar
waybar > /dev/null 2>&1 &

killall -SIGUSR1 kitty

hyprctl reload
