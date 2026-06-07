#!/usr/bin/env bash
# wallhaven-fetch.sh — explorá, buscá, previsualizá y descargá wallpapers de wallhaven.cc
#
# Flujo:
#   1. Al abrir: carga los POPULARES (toplist) y los muestra en grid con preview.
#   2. El grid tiene un INPUT visible arriba: escribí un término + Enter para
#      buscar en wallhaven; el grid se actualiza con esos resultados.
#   3. Elegís un wallpaper (Enter sobre su thumbnail) → descarga el FULL a
#      ~/Wallpapers/ y lo aplica con awww.
#
# Solo baja thumbnails para previsualizar; el full se baja del que elijas.
# API key opcional en ~/.config/wallhaven/apikey (fuera de git, chmod 600).
# Deps: curl, jq, rofi, awww, notify-send.

set -euo pipefail

WALLPAPER_DIR="$HOME/Wallpapers"
GRID_THEME="$HOME/.config/rofi/wallselect/style.rasi"
APIKEY_FILE="$HOME/.config/wallhaven/apikey"
THUMB_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/wallhaven-thumbs"
COUNT=48                # cuántos resultados mostrar (2 páginas exactas de 24)
MIN_RES="1920x1080"

# theme-str: hace visible un inputbar en el grid (el theme wallselect lo oculta).
# Sin esto no se puede escribir para buscar.
# El theme wallselect usa font tamaño 1 (oculta nombres en el grid). Eso haría
# el texto del input invisible → override font 13 en prompt/entry.
INPUTBAR_STR='
  mainbox { children: ["inputbar","listview"]; }
  inputbar { enabled: true; padding: 12px 16px; margin: 0 0 16px 0;
             background-color: #0f1623cc; border-radius: 12px;
             children: ["prompt","entry"]; }
  prompt { enabled: true; text-color: #00b4d8; padding: 0 10px 0 0;
           font: "JetBrainsMono Nerd Font 13"; }
  entry  { enabled: true; text-color: #cdd6f4; cursor: text;
           font: "JetBrainsMono Nerd Font 13";
           placeholder: "Escribí + Enter para buscar en Wallhaven…";
           placeholder-color: #7a8ba8; }
'

mkdir -p "$WALLPAPER_DIR" "$THUMB_CACHE"
APIKEY=""
[[ -f "$APIKEY_FILE" ]] && APIKEY="$(< "$APIKEY_FILE")"

declare -A FULL_OF
ROWS=()

# Consulta la API. Sin query → toplist (populares). Con query → relevance.
# Llena ROWS + FULL_OF y baja los thumbnails en paralelo.
fetch() {
  local query="$1" sorting resp page
  if [[ -z "$query" ]]; then sorting="toplist"; else sorting="relevance"; fi

  # La API devuelve 24 por página → paginamos hasta juntar COUNT (50 ≈ 3 págs).
  ROWS=()
  page=1
  while (( ${#ROWS[@]} < COUNT && page <= 4 )); do
    resp="$(curl -fsSL --get "https://wallhaven.cc/api/v1/search" \
      ${query:+--data-urlencode "q=$query"} \
      --data-urlencode "categories=111" \
      --data-urlencode "purity=100" \
      --data-urlencode "sorting=$sorting" \
      --data-urlencode "atleast=$MIN_RES" \
      --data-urlencode "page=$page" \
      ${APIKEY:+--data-urlencode "apikey=$APIKEY"} 2>/dev/null)" || {
        notify-send -u critical -t 3000 "󰸉 Wallhaven" "Error de red"; return 1; }
    mapfile -t newrows < <(printf '%s' "$resp" \
      | jq -r '.data[] | "\(.id)\t\(.thumbs.large)\t\(.path)\t\(.resolution)"' 2>/dev/null)
    (( ${#newrows[@]} == 0 )) && break
    ROWS+=("${newrows[@]}")
    (( page++ ))
  done
  # recortar a COUNT exacto
  ROWS=("${ROWS[@]:0:COUNT}")

  FULL_OF=()
  for row in "${ROWS[@]}"; do
    IFS=$'\t' read -r id thumb full res <<< "$row"
    FULL_OF["$id"]="$full"
    local tpath="$THUMB_CACHE/$id.jpg"
    [[ -f "$tpath" ]] || curl -fsSL "$thumb" -o "$tpath" 2>/dev/null &
  done
  wait
}

# Entries del grid: cada wallpaper con su thumbnail como icono.
show_grid() {
  for row in "${ROWS[@]}"; do
    IFS=$'\t' read -r id thumb full res <<< "$row"
    local tpath="$THUMB_CACHE/$id.jpg"
    [[ -f "$tpath" ]] && printf '%s (%s)\0icon\x1f%s\n' "$id" "$res" "$tpath"
  done
}

# --- Flujo principal ---
notify-send -u low -t 1200 "󰸉 Wallhaven" "Cargando populares…"
fetch "" || exit 1

while true; do
  # -no-custom NO seteado: si lo escrito no coincide con ningún thumbnail,
  # rofi devuelve el texto tal cual → lo tratamos como término de búsqueda.
  CHOICE="$(show_grid | rofi -dmenu -i -show-icons -p "Wallhaven 󰋫" \
    -theme "$GRID_THEME" -theme-str "$INPUTBAR_STR" \
    -mesg "Escribí + Enter = buscar  •  Enter sobre una imagen = descargar")"
  [[ -z "$CHOICE" ]] && exit 0

  # ¿Es un wallpaper (su id está en FULL_OF) o un término de búsqueda nuevo?
  chosen_id="${CHOICE%% *}"
  if [[ -z "${FULL_OF[$chosen_id]:-}" ]]; then
    # Texto que no es un id → término de búsqueda. Refrescar el grid.
    notify-send -u low -t 1200 "󰸉 Wallhaven" "Buscando \"$CHOICE\"…"
    fetch "$CHOICE" || continue
    [[ ${#ROWS[@]} -eq 0 ]] && notify-send -u normal -t 2500 "󰸉 Wallhaven" "Sin resultados para \"$CHOICE\""
    continue
  fi

  # Wallpaper elegido: descargar el full y aplicar.
  full="${FULL_OF[$chosen_id]}"
  dest="$WALLPAPER_DIR/wallhaven-$(basename "$full")"
  notify-send -u low -t 1500 "󰸉 Wallhaven" "Descargando en alta resolución…"
  if curl -fsSL "$full" -o "$dest" 2>/dev/null; then
    notify-send -u low -t 2500 "󰸉 Wallhaven" "Aplicado y guardado en ~/Wallpapers"
    awww img "$dest" --transition-type any --transition-duration 0.6 \
      --transition-pos 0.5,0.5 --transition-fps 60 2>/dev/null &
    pkill -SIGUSR2 waybar >/dev/null 2>&1 || true
  else
    notify-send -u critical -t 3000 "󰸉 Wallhaven" "Error al descargar"
  fi
  break
done
