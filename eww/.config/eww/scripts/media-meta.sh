#!/usr/bin/env bash
# Metadatos "lentos" del reproductor: título, artista, álbum, player, shuffle, loop.
# Sale por stdout como JSON, para el defpoll mpris_meta (2s).
#
# El `status` NO está acá a propósito: vive en media-tick.sh (500ms), porque de él
# sale el ícono play/pausa y con 2s de latencia se sentía tarde al pausar.
#
# shuffle y loop no vienen en `metadata`, son subcomandos aparte, así que suman
# dos invocaciones. Van en este poll lento porque solo cambian cuando los tocás.

set -uo pipefail

VACIO='{"title":"Nada sonando","artist":"","album":"","player":"","shuffle":"Off","loop":"None"}'

P=$(playerctl --list-all 2>/dev/null | grep -i spotify | head -1)
[ -z "$P" ] && P=$(playerctl --list-all 2>/dev/null | head -1)
[ -z "$P" ] && {
  echo "$VACIO"
  exit 0
}

IFS='|' read -r T A AL < <(
  playerctl --player="$P" metadata --format '{{title}}|{{artist}}|{{album}}' 2>/dev/null
)
[ -z "${T:-}" ] && {
  echo "$VACIO"
  exit 0
}

# On | Off
SH=$(playerctl --player="$P" shuffle 2>/dev/null)
# None | Track | Playlist — son TRES estados, no dos
LP=$(playerctl --player="$P" loop 2>/dev/null)

jq -n --arg t "$T" --arg a "$A" --arg al "${AL:-}" --arg p "$P" \
  --arg sh "${SH:-Off}" --arg lp "${LP:-None}" \
  '{title:$t,artist:$a,album:$al,player:$p,shuffle:$sh,loop:$lp}'
