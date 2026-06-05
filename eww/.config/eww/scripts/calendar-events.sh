#!/usr/bin/env bash
#
# calendar-events.sh — emite los próximos eventos como JSON para el widget eww.
#
# Output: array JSON con objetos { calendar, date, time, title }
# Lo lee `(defpoll events ...)` en eww.yuck y se itera con `(for ... in ...)`.
#
# Por qué borrar la cache de khal antes:
#   El bot reescribe .ics con UID determinístico (mismo filename, contenido
#   nuevo). khal a veces no detecta el cambio si el mtime es muy cercano al
#   anterior, y muestra fechas viejas. Borrar la cache fuerza reindexar.
#   Costo trivial: regenerar la cache toma <100ms.
#
# La ventana es 60d para captar parciales del mes próximo.

set -euo pipefail

rm -f "$HOME/.cache/khal/khal.db"

khal list today 60d \
  --day-format "" \
  --format "{calendar}|{start-date}|{start-time}|{title}" \
  2>/dev/null \
| jq -R -s '
    split("\n")
    | map(select(length > 0))
    | map(split("|"))
    | map(select(length == 4))
    | map({
        calendar: .[0],
        date:     .[1],
        time:     .[2],
        title:    .[3]
      })
    | map(select(.calendar != "pedco"))   # filtramos el calendar del bot
    | .[0:8]                              # máx 8 eventos para no estirar el popup
  '
