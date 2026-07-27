#!/usr/bin/env bash
# Descarga la portada del player a /tmp/eww-art/ y emite su ruta por stdout
# (cadena vacía si no hay).
#
# Cachea por mpris:trackid. Antes hacía curl en CADA invocación y el defpoll lo
# llama cada 3s → 20 descargas por minuto de la misma imagen, 1200 por hora.
#
# Uso: mpris-art.sh <player>

set -uo pipefail

PLAYER="${1:-}"
DIR="/tmp/eww-art"
MAX_CACHE=20

[ -z "$PLAYER" ] && {
  echo ""
  exit 0
}

TID=$(playerctl --player="$PLAYER" metadata mpris:trackid 2>/dev/null)
[ -z "$TID" ] && {
  echo ""
  exit 0
}

mkdir -p "$DIR"

# el trackid es una ruta D-Bus (/com/spotify/track/XXXX) → nombre de archivo plano
KEY=$(printf '%s' "$TID" | tr -c '[:alnum:]' '_')
DEST="$DIR/$KEY.png"

# ya está en cache: salir sin tocar la red. Éste es el camino del 99% de las
# invocaciones, porque el poll corre cada 3s y las canciones duran minutos.
if [ -s "$DEST" ]; then
  echo "$DEST"
  exit 0
fi

URL=$(playerctl --player="$PLAYER" metadata mpris:artUrl 2>/dev/null)
[ -z "$URL" ] && {
  echo ""
  exit 0
}

case "$URL" in
file://*) cp "${URL#file://}" "$DEST" 2>/dev/null ;;
http*) curl -sL --max-time 5 -o "$DEST" "$URL" 2>/dev/null ;;
*)
  echo ""
  exit 0
  ;;
esac

if [ -s "$DEST" ]; then
  echo "$DEST"
else
  rm -f "$DEST" # descarga fallida: no dejar un archivo de 0 bytes cacheado
  echo ""
fi

# podar el cache a las MAX_CACHE portadas más recientes
find "$DIR" -maxdepth 1 -name '*.png' -printf '%T@ %p\n' 2>/dev/null |
  sort -rn | tail -n +$((MAX_CACHE + 1)) | cut -d' ' -f2- |
  while IFS= read -r f; do rm -f "$f"; done
