#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG (ajusta rutas) ---
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-rofi"
mkdir -p "$CACHE_DIR"

ROFI_THEME="${ROFI_THEME:-$HOME/.config/rofi/cliphist/style.rasi}"
ROFI_PROMPT="${ROFI_PROMPT:-Clipboard}"

THUMB_PX="${THUMB_PX:-520}"
THUMB_GEOM="${THUMB_GEOM:-${THUMB_PX}x${THUMB_PX}}"

MAX_ITEMS="${MAX_ITEMS:-250}"
ONLY_IMAGES="${ONLY_IMAGES:-0}"   # 1 => solo imágenes

# --- helpers ---
have() { command -v "$1" >/dev/null 2>&1; }
die() { echo "Error: $*" >&2; exit 1; }

have_magick() { have magick; }
have_convert() { have convert; }

make_thumb() {
  local in="$1"
  local out="$2"

  if have_magick; then
    magick "$in" -auto-orient \
      -resize "${THUMB_GEOM}^" \
      -gravity center -extent "$THUMB_GEOM" \
      -strip \
      -unsharp 0x0.75+0.75+0.008 \
      "png:$out"
  elif have_convert; then
    convert "$in" -auto-orient \
      -resize "${THUMB_GEOM}^" \
      -gravity center -extent "$THUMB_GEOM" \
      -strip \
      -unsharp 0x0.75+0.75+0.008 \
      "png:$out"
  else
    return 1
  fi
}

# Detecta entradas imagen de cliphist (tu formato actual)
is_image_line() {
  local line="$1"
  [[ "$line" == *"[[ binary data"* ]] && return 0
  [[ "$line" == *"image/"* ]] && return 0
  return 1
}

# Build rofi entries (MISMO ORDEN que cliphist list)
# Para imágenes: label limpio + icon + :::id
# Para texto: id + texto
build_menu() {
  local count=0

  cliphist list | while IFS= read -r line; do
    ((count++)) || true
    ((count > MAX_ITEMS)) && break

    id="${line%% *}"
    rest="${line#"$id"}"; rest="${rest# }"

    if is_image_line "$line"; then
      thumb="${CACHE_DIR}/${id}.png"

      if [[ ! -s "$thumb" ]]; then
        tmp_in="${CACHE_DIR}/${id}.bin"
        rm -f "$tmp_in" || true

        if cliphist decode "$id" > "$tmp_in" 2>/dev/null; then
          if ! make_thumb "$tmp_in" "$thumb" 2>/dev/null; then
            rm -f "$thumb" || true
          fi
          rm -f "$tmp_in" || true
        fi
      fi

      # Label limpio: no mostramos nada del contenido.
      # Guardamos el id con separador para poder copiar luego.
      label="  :::$id"

      if [[ -s "$thumb" ]]; then
        printf '%s\0icon\x1f%s\n' "$label" "$thumb"
      else
        printf '%s\n' "$label"
      fi
    else
      [[ "$ONLY_IMAGES" == "1" ]] && continue

      short="$rest"
      short="${short//$'\t'/ }"
      short="${short//$'\n'/ }"
      if ((${#short} > 160)); then short="${short:0:160}…"; fi

      # Texto: mantenemos visible el id al inicio
      printf '%s %s\n' "$id" "$short"
    fi
  done
}

# deps
have cliphist || die "Missing dependency: cliphist"
have wl-copy  || die "Missing dependency: wl-copy"
have rofi     || die "Missing dependency: rofi"

sel="$(
  build_menu | rofi -dmenu -i -show-icons -p "$ROFI_PROMPT" -theme "$ROFI_THEME"
)" || exit 0

# Extraer id:
# - Imágenes: "  :::123" => 123
# - Texto: "123 algo..." => 123
id=""
if [[ "$sel" == *":::"* ]]; then
  id="${sel##*:::}"
else
  id="${sel%% *}"
fi

# sanitize
id="$(printf '%s' "$id" | tr -cd '0-9')"
[[ -n "$id" ]] || exit 0

cliphist decode "$id" | wl-copy
