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
DIAS=(dom lun mar mié jue vie sáb)

emit() { jq -nc --arg text "$1" --arg tooltip "$2" --arg class "$3" \
  '{text:$text,tooltip:$tooltip,class:$class}'; }

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

texto=''; clase=''; tooltip=''
while IFS=$'\t' read -r s e allday cal title; do
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

  # A la barra va lo académico (pedco = clases, estudio = lecturas). El bloque de
  # trabajo ocupa 8h de lunes a viernes: en la barra sería ruido, en el tooltip es contexto.
  [ -n "$texto" ] && continue
  [ "$fin" -lt "$ahora" ] && continue
  [ "$cal" = personal ] && continue

  if [ "$ini" -le "$ahora" ]; then
    texto="$ICON ahora · $title"
    clase=now
  elif [ "$allday" = true ]; then
    texto="$ICON $title"
  elif [ "${s%% *}" = "$hoy" ]; then
    falta=$(( (ini - ahora) / 60 ))
    if [ "$falta" -lt 60 ]; then
      texto="$ICON ${s##* } $title · en ${falta}m"
      clase=soon
    else
      texto="$ICON ${s##* } $title · en $((falta / 60))h $((falta % 60))m"
    fi
  else
    dia=${DIAS[$(date -d "${s%% *}" +%w)]}
    texto="$ICON $dia ${s##* } $title"
  fi
done <<< "$eventos"

if [ -z "$texto" ]; then
  emit "" "sin eventos por delante en 7 días" ""
  exit 0
fi

emit "$texto" "${tooltip%$'\n'}" "$clase"
