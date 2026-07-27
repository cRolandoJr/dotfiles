#!/usr/bin/env bash
# Baja lyrics sincronizadas de lrclib.net y las cachea. Corre en background desde
# media-tick.sh, una vez por canción.
#
# MPRIS no expone lyrics: verificado que xesam:asText y xesam:lyrics no existen
# en Spotify. lrclib es gratis y sin API key.
#
# Uso: lyrics-fetch.sh <artista> <título> <destino.lrc>

set -uo pipefail

ART="${1:-}"
TIT="${2:-}"
DEST="${3:-}"

[ -z "$ART" ] || [ -z "$TIT" ] || [ -z "$DEST" ] && exit 0
[ -f "$DEST" ] && exit 0 # ya resuelto (con letra o con marcador)

mkdir -p "$(dirname "$DEST")"

# escritura atómica: si dos ticks disparan el fetch a la vez, ninguno lee un
# archivo a medio escribir
TMP=$(mktemp "${DEST}.XXXXXX")
trap 'rm -f "$TMP"' EXIT

R=$(curl -s --max-time 8 -G "https://lrclib.net/api/get" \
  --data-urlencode "artist_name=$ART" \
  --data-urlencode "track_name=$TIT" 2>/dev/null)

# Los marcadores evitan reintentar en cada tick de 500ms. Sin ellos, una canción
# sin letra dispararía un curl dos veces por segundo para siempre.
if [ -z "$R" ] || ! printf '%s' "$R" | jq -e . >/dev/null 2>&1; then
  echo "NONE" >"$TMP" # sin red o respuesta no-JSON
  mv -f "$TMP" "$DEST"
  exit 0
fi

# Un 404 de lrclib es JSON VÁLIDO: {"statusCode":404,"name":"TrackNotFound"}.
# Sin este chequeo pasaba el filtro de arriba y terminaba marcado como PLAIN,
# que miente: no es que falten los timestamps, es que no existe la canción.
if printf '%s' "$R" | jq -e 'has("statusCode")' >/dev/null 2>&1; then
  echo "NONE" >"$TMP"
  mv -f "$TMP" "$DEST"
  exit 0
fi

if [ "$(printf '%s' "$R" | jq -r '.instrumental // false')" = "true" ]; then
  echo "INSTRUMENTAL" >"$TMP"
  mv -f "$TMP" "$DEST"
  exit 0
fi

SYNC=$(printf '%s' "$R" | jq -r '.syncedLyrics // ""')
if [ -n "$SYNC" ]; then
  printf '%s\n' "$SYNC" >"$TMP"
else
  echo "PLAIN" >"$TMP" # hay letra pero sin timestamps: no se puede seguir
fi
mv -f "$TMP" "$DEST"
