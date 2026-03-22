#!/usr/bin/env bash
# Selector de wallpaper SOLO para Niri (usa swww) con previsualización en rofi.
# Copia/enlaza la imagen a ~/.config/niri/bg.jpg para que el overview la muestre.
# No envía señales a Niri (evita cierres de sesión).
set -euo pipefail

WALL_DIR="${WALL_DIR:-$HOME/Wallpapers}"
ROFI_THEME="${ROFI_THEME:-$HOME/.config/rofi/wallselect/style.rasi}"
NIRI_BG_PATH="${NIRI_BG_PATH:-$HOME/.config/niri/bg.jpg}"

# 1) Asegura swww-daemon
if ! pgrep -x swww-daemon >/dev/null 2>&1; then
  nohup swww-daemon >/dev/null 2>&1 & disown
  # Espera breve para que el socket esté listo
  sleep 0.2
fi

# 2) Genera lista con iconos para rofi (miniaturas)
#   - Cada línea: "TEXTO\0icon\x1f/RUTA"
#   - Usamos printf para insertar 0x00 y 0x1F correctamente
SEL="$(
  while IFS= read -r -d '' img; do
    # Muestra solo el nombre como texto y usa la imagen como icono
    base="${img##*/}"
    printf '%s\0icon\x1f%s\n' "$base" "$img"
  done < <(find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \) -print0 \
           | sort -z) \
  | rofi -dmenu -i -p "Wallpaper" -show-icons -markup-rows -theme "$ROFI_THEME"
)"

# Cancelado
[ -z "${SEL:-}" ] && exit 0

# 3) Recupera la ruta real de la imagen seleccionada a partir del texto y el icono
#    Rofi nos devuelve solo el "texto" de la entrada (base filename).
#    Buscamos la primera coincidencia en WALL_DIR (case-sensitive).
TARGET="$(find "$WALL_DIR" -type f -name "$SEL" -print -quit)"
if [ -z "${TARGET:-}" ] || [ ! -f "$TARGET" ]; then
  notify-send "Niri Wallpaper" "No se encontró el archivo para: $SEL"
  exit 1
fi

# 4) Aplica con swww (sin tocar Niri ni matar procesos)
swww img "$TARGET" --transition-type grow --transition-fps 60 --transition-duration 0.35 >/dev/null 2>&1 || true
colorwaybar "$WALL_DIR/$TARGET"
# 5) Actualiza el fondo que lee el overview de Niri
mkdir -p "$(dirname "$NIRI_BG_PATH")"
# Usa symlink (rápido y sin duplicar espacio). Si prefieres copiar, usa: cp -f "$TARGET" "$NIRI_BG_PATH"
ln -sf "$TARGET" "$NIRI_BG_PATH"

# 6) No reiniciamos ni señalizamos Niri. El overview tomará el nuevo bg al abrirse.
notify-send "Niri Wallpaper" "Aplicado: ${TARGET##*/}"
