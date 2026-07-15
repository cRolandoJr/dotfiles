#!/usr/bin/env bash
# Descarga artwork de Spotify a /tmp/eww-spotify-art.png.
# Llamar periódicamente o desde un defpoll que refresca la URL.
DEST="/tmp/eww-spotify-art.png"

PLAYER="${1:-spotify}"

URL=$(playerctl --player="$PLAYER" metadata mpris:artUrl 2>/dev/null)

# Sin artwork → borrar el DEST para que el hub muestre el glyph 󰎈 (poll devuelve "").
if [[ -z "$URL" ]]; then
  rm -f "$DEST"
  exit 0
fi

if [[ "$URL" == file://* ]]; then
  cp "${URL#file://}" "$DEST" 2>/dev/null
elif [[ "$URL" == http* ]]; then
  curl -sL --max-time 5 -o "$DEST" "$URL" 2>/dev/null
fi
