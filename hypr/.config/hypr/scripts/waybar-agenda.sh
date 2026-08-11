#!/usr/bin/env bash
# Próximo evento de khal en la barra. Lee solo los .ics: no sabe que existe PEDCO.
#
# Tres cosas del terreno que rompen la versión obvia:
#   * `khal --json` emite UN ARRAY POR DÍA (vacíos incluidos) → es NDJSON, hay que aplanar.
#   * las fechas salen en el dateformat del config (%d-%m-%Y), no ISO: `date -d` las rechaza.
#   * deduplicar por `uid` colapsa las ocurrencias de una serie (Wind pasa de 5 días a 1);
#     la clave es (uid, start-date).
# El JSON se emite con jq y no con printf porque los títulos son texto de la cátedra.
set -euo pipefail

ICON='󰃭'
# Estado del plegado. Va en XDG_RUNTIME_DIR a propósito: se borra al reiniciar,
# así el default vuelve a ser contraído sin tener que limpiarlo a mano.
ESTADO="${XDG_RUNTIME_DIR:-/tmp}/waybar-agenda.expandido"
SENAL=12   # la 11 la usa custom/gamemode
DIAS=(dom lun mar mié jue vie sáb)

emit() { jq -nc --arg text "$1" --arg tooltip "$2" --arg class "$3" \
  '{text:$text,tooltip:$tooltip,class:$class}'; }

# Un click alterna contraído/expandido y le avisa a waybar por señal, igual que
# waybar-gamemode.sh. Sin la señal habría que esperar el interval de 60s.
if [ "${1:-}" = toggle ]; then
  if [ -e "$ESTADO" ]; then rm -f "$ESTADO"; else : > "$ESTADO"; fi
  pkill -RTMIN+$SENAL waybar 2>/dev/null || true
  exit 0
fi

if ! command -v khal >/dev/null 2>&1; then
  emit "$ICON ?" "khal no está en el PATH" error
  exit 0
fi

# stderr aparte: khal avisa por ahí (un .ics ilegible se saltea con exit 0) y
# mezclarlo con stdout rompería el JSON.
raw=$(khal list --json start-date --json end-date --json start-time \
        --json end-time --json title --json calendar --json uid \
        today 7d 2>/dev/null) || raw=''

# Normaliza a TSV ordenable: fecha ISO + hora, un evento por línea.
eventos=$(printf '%s' "$raw" | jq -r -s '
  (add // [])
  | unique_by(.uid + "|" + .["start-date"])
  | map(
      (.["start-date"] | split("-") | "\(.[2])-\(.[1])-\(.[0])") as $sd
    | ((.["end-date"] // .["start-date"]) | split("-") | "\(.[2])-\(.[1])-\(.[0])") as $ed
    | (if .["start-time"] == "" then "00:00" else .["start-time"] end) as $st
    | (if .["end-time"] == "" then "23:59" else .["end-time"] end) as $et
    | { s: "\($sd) \($st)", e: "\($ed) \($et)",
        allday: (.["start-time"] == ""), cal: .calendar, title: .title }
    )
  | sort_by(.s)
  | .[] | [.s, .e, (.allday | tostring), .cal, .title] | @tsv
' 2>/dev/null) || {
  # khal devolvió algo que no es su JSON: falla visible, no "sin eventos".
  emit "$ICON !" "khal devolvió una salida que no se pudo parsear" error
  exit 0
}

if [ -z "$eventos" ]; then
  emit "" "sin eventos en los próximos 7 días" ""
  exit 0
fi

ahora=$(date +%s)
hoy=$(date +%Y-%m-%d)

texto=''; corto=''; clase=''; tooltip=''
while IFS=$'\t' read -r s e allday _cal title; do
  ini=$(date -d "$s" +%s)
  fin=$(date -d "$e" +%s)

  # Línea del tooltip para todo lo que todavía no terminó.
  if [ "$fin" -ge "$ahora" ]; then
    dia=${DIAS[$(date -d "${s%% *}" +%w)]}
    if [ "$allday" = true ]; then
      tooltip+="$dia ${s%% *} · $title"$'\n'
    else
      tooltip+="$dia ${s##* } · $title"$'\n'
    fi
  fi

  # El primero que no terminó es el que va en la barra.
  [ -n "$texto" ] && continue
  [ "$fin" -lt "$ahora" ] && continue

  if [ "$ini" -le "$ahora" ]; then
    texto="$ICON ahora · $title"
    corto="$ICON ahora"
    clase=now
  elif [ "$allday" = true ]; then
    texto="$ICON $title"
    corto="$ICON hoy"
  elif [ "${s%% *}" = "$hoy" ]; then
    falta=$(( (ini - ahora) / 60 ))
    corto="$ICON ${s##* }"
    if [ "$falta" -lt 60 ]; then
      texto="$ICON ${s##* } $title · en ${falta}m"
      clase=soon
    else
      texto="$ICON ${s##* } $title · en $((falta / 60))h $((falta % 60))m"
    fi
  else
    dia=${DIAS[$(date -d "${s%% *}" +%w)]}
    texto="$ICON $dia ${s##* } $title"
    corto="$ICON $dia ${s##* }"
  fi
done <<< "$eventos"

if [ -z "$texto" ]; then
  emit "" "sin eventos por delante en 7 días" ""
  exit 0
fi

# Contraído deja solo el icono y la hora; el título largo es lo que copaba la
# barra. El tooltip trae todo en los dos modos.
visible=$corto
[ -e "$ESTADO" ] && visible=$texto

emit "$visible" "${tooltip%$'\n'}" "$clase"
