#!/usr/bin/env bash
# Estado "rápido" del reproductor: status, posición, porcentaje y tiempos.
# Sale por stdout como JSON, para el defpoll media_tick (500ms).
#
# Por qué separado de mpris_meta: el anillo de progreso y el ícono play/pausa
# necesitan medio segundo de resolución, pero el título y el artista no cambian
# tan rápido. Ese poll queda en 2s.
#
# Una SOLA invocación de playerctl: medido ~6.5ms cada una, así que tres por tick
# a 500ms serían ~4% de un core solo en arrancar procesos.
#
# El campo `lyric` existe pero va vacío: se llena en la Fase 5 del plan.

set -uo pipefail

VACIO='{"status":"stopped","position":0,"pct":0,"elapsed":"","total":"","lyric":""}'

P=$(playerctl --list-all 2>/dev/null | grep -i spotify | head -1)
[ -z "$P" ] && P=$(playerctl --list-all 2>/dev/null | head -1)
[ -z "$P" ] && {
  echo "$VACIO"
  exit 0
}

# status | posición (µs) | duración (µs) — todo de una
IFS='|' read -r ST POS LEN < <(
  playerctl --player="$P" metadata \
    --format '{{lc(status)}}|{{position}}|{{mpris:length}}' 2>/dev/null
)

[ -z "${ST:-}" ] && {
  echo "$VACIO"
  exit 0
}

# playerctl devuelve vacío en vez de 0 si el campo no existe
POS=${POS:-0}
LEN=${LEN:-0}
[ -z "$POS" ] && POS=0
[ -z "$LEN" ] && LEN=0

pos=$((POS / 1000000))
len=$((LEN / 1000000))

if [ "$len" -gt 0 ]; then
  pct=$((pos * 100 / len))
  elapsed=$(printf '%d:%02d' $((pos / 60)) $((pos % 60)))
  total=$(printf '%d:%02d' $((len / 60)) $((len % 60)))
else
  # streams de radio: sin duración. Anillo quieto y tiempos ocultos en vez de
  # saltar a valores raros.
  pct=0
  elapsed=""
  total=""
fi

# ── Lyrics sincronizadas ──────────────────────────────────────────────────────
# La línea se DERIVA de la posición, por eso vive en este tick y no en un poll
# aparte: pedirlas por separado significaría consultar dos veces lo mismo.
lyric=""
IFS='|' read -r ART TIT < <(
  playerctl --player="$P" metadata --format '{{artist}}|{{title}}' 2>/dev/null
)

if [ -n "${ART:-}" ] && [ -n "${TIT:-}" ]; then
  KEY=$(printf '%s|%s' "$ART" "$TIT" | sha1sum | cut -d' ' -f1)
  LRC="/tmp/eww-lyrics/$KEY.lrc"

  if [ ! -f "$LRC" ]; then
    # primera vez que vemos esta canción: a bajarla, sin bloquear el tick
    "$HOME/.config/eww/scripts/lyrics-fetch.sh" "$ART" "$TIT" "$LRC" >/dev/null 2>&1 &
  else
    read -r MARK <"$LRC"
    case "$MARK" in
    INSTRUMENTAL) lyric="♪ instrumental" ;;
    PLAIN | NONE) lyric="" ;;
    *)
      # última línea cuyo timestamp sea <= pos. Sin grep/awk por línea: el
      # while corre en el mismo bash, así que son 0 subprocesos.
      while IFS= read -r l; do
        case "$l" in
        \[[0-9]*)
          mm=${l:1:2}
          ss=${l:4:2}
          t=$((10#$mm * 60 + 10#$ss))
          [ "$t" -le "$pos" ] || break
          txt=${l#*] }
          [ -n "$txt" ] && [ "$txt" != "$l" ] && lyric="$txt"
          ;;
        esac
      done <"$LRC"
      ;;
    esac
  fi
fi

jq -n --arg s "$ST" --argjson p "$pos" --argjson pc "$pct" \
  --arg e "$elapsed" --arg t "$total" --arg l "$lyric" \
  '{status:$s,position:$p,pct:$pc,elapsed:$e,total:$t,lyric:$l}'
