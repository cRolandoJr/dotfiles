#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="$HOME/Wallpapers"
THEME="$HOME/.config/rofi/wallselect/style.rasi"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/rofi-wallpapers"
THUMB_SIZE=420   # tamaño real del png (rofi luego lo escala a 260px)

mkdir -p "$CACHE_DIR"

die() { echo "Error: $*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"; }

need rofi
need find
need basename

# Para thumbnails bonitos: ImageMagick (convert/magick) o ffmpegthumbnailer (opcional)
IM_CONVERT=""
if command -v magick >/dev/null 2>&1; then
  IM_CONVERT="magick"
elif command -v convert >/dev/null 2>&1; then
  IM_CONVERT="convert"
fi

if [[ ! -d "$WALLPAPER_DIR" ]]; then
  die "La carpeta $WALLPAPER_DIR no existe."
fi

thumb_for() {
  local file="$1"
  local base hash out
  base="$(basename "$file")"
  hash="$(printf '%s' "$file" | sha1sum | awk '{print $1}')"
  out="$CACHE_DIR/${hash}-${base}.png"

  # regen si no existe o si wallpaper es más nuevo
  if [[ -f "$out" && "$out" -nt "$file" ]]; then
    printf '%s\n' "$out"
    return 0
  fi

  # Si no hay ImageMagick, fallback al archivo original
  if [[ -z "$IM_CONVERT" ]]; then
    printf '%s\n' "$file"
    return 0
  fi

  # square crop centered (cover) + ligero sharpening
  "$IM_CONVERT" "$file" \
    -auto-orient \
    -resize "${THUMB_SIZE}x${THUMB_SIZE}^" \
    -gravity center \
    -extent "${THUMB_SIZE}x${THUMB_SIZE}" \
    -strip \
    -unsharp 0x0.75+0.75+0.008 \
    "$out" >/dev/null 2>&1 || {
      # si falla, usa original
      printf '%s\n' "$file"
      return 0
    }

  printf '%s\n' "$out"
}

list_wallpapers() {
  find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
  | sort \
  | while IFS= read -r file; do
      filename="$(basename "$file")"
      icon="$(thumb_for "$file")"
      # rofi icon hint
      printf '%s\0icon\x1f%s\n' "$filename" "$icon"
    done
}

# Loop: permite borrar varios (Alt+D) sin salir; Enter aplica; Esc cierra.
# Alt+D (no Shift+D) porque las letras van al filtro de texto del grid;
# Alt no compite con el typing y dispara el keybind limpio.
# rofi exit codes: 0=Enter, 1=Esc/cancel, 10=kb-custom-1 (Alt+D).
SELECTED=""
while true; do
  set +e
  SELECTED="$(list_wallpapers | rofi -dmenu -i -show-icons -p "Wallpaper" -theme "$THEME" \
    -kb-custom-1 "Alt+d" \
    -mesg "Enter: aplicar  •  Alt+D: borrar")"
  ec=$?
  set -e

  case $ec in
    1) exit 0 ;;                       # Esc → salir sin cambios
    10)                                # Alt+D → borrar el resaltado (rm) y re-abrir
      [[ -z "$SELECTED" ]] && continue
      del_path="$WALLPAPER_DIR/$SELECTED"
      if [[ -f "$del_path" ]]; then
        rm -f "$del_path"
        # limpiar el thumbnail cacheado del borrado
        rm -f "$CACHE_DIR"/*"$SELECTED".png 2>/dev/null || true
        notify-send -u low -t 1500 "󰸉 Wallpaper" "Borrado: $SELECTED"
      fi
      continue ;;                      # vuelve a mostrar la lista actualizada
    0) break ;;                        # Enter → aplicar
    *) exit 0 ;;
  esac
done

[[ -z "$SELECTED" ]] && exit 0
FULL_PATH="$WALLPAPER_DIR/$SELECTED"
[[ -f "$FULL_PATH" ]] || die "No existe: $FULL_PATH"

# Cambiar wallpaper con awww (el daemon del setup; ver memoria wallpaper-stack).
# swww queda como fallback por si algún día se migra, pero NO es el elegido.
if command -v awww >/dev/null 2>&1; then
  awww img "$FULL_PATH" \
    --transition-type any \
    --transition-duration 0.6 \
    --transition-pos 0.5,0.5 \
    --transition-step 90 \
    --transition-fps 60 &
elif command -v swww >/dev/null 2>&1; then
  swww img "$FULL_PATH" \
    --transition-type grow \
    --transition-pos 0.5,0.5 \
    --transition-step 90 \
    --transition-fps 60 &
else
  die "Necesito awww (o swww)."
fi

# Reload “ecosistema” (sin escalera)
{
  pkill -SIGUSR2 waybar >/dev/null 2>&1 || true
} &

exit 0
