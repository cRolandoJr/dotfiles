#!/usr/bin/env bash
set -euo pipefail

WALLDIR="${HOME}/Wallpapers"

# Lista imagenes comunes (hasta 2 niveles de profundidad)
choice="$(
  find "$WALLDIR" -maxdepth 2 -type f \( \
    -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \
  \) -printf '%P\n' \
  | sort \
  | fuzzel --prompt="Wallpaper> " --dmenu
)" || exit 0

wall="${WALLDIR}/${choice}"
[ -f "$wall" ] || exit 1

# Reiniciar hyprpaper con el nuevo fondo
pkill -x hyprpaper 2>/dev/null || true

# Usar ruta fija para evitar acumulacion de archivos temporales
cfg="${HOME}/.config/hypr/hyprpaper-current.conf"
cat > "$cfg" <<EOF
preload = $wall
wallpaper = ,$wall
EOF

hyprpaper -c "$cfg" &
disown

exit 0
