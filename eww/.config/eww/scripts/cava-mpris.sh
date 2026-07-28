#!/usr/bin/env bash
# Emite las barras del ecualizador SOLO mientras hay algo reproduciéndose.
# Salida: un array JSON de 14 enteros 0-100 por línea, para el deflisten cava_bars.
#
# Por qué atado al player: cava a 30fps es CPU constante. Con esto no existe
# mientras no haya música, así que no come batería de fondo.
#
# playerctl --follow es orientado a eventos (no hay sleep girando) y emite el
# estado inicial al arrancar, así que no hay ventana ciega. Verificado 27-jul-2026.

set -uo pipefail

BARS=24
ZEROS="[$(printf '0,%.0s' $(seq 1 $((BARS - 1))))0]"
CAVA_PID=""

# Sin cava instalado el reproductor tiene que seguir funcionando: emitimos ceros
# y salimos. El zócalo queda plano en vez de romper el hub.
if ! command -v cava >/dev/null 2>&1; then
  echo "$ZEROS"
  exec sleep infinity
fi

# Una sola instancia: cada `eww reload` arranca un deflisten nuevo pero NO mata
# el viejo, así que se acumulaban (medido: de 2 a 5 tras un solo reload). El que
# arranca se encarga de bajar al anterior.
PIDFILE=/tmp/eww-cava-mpris.pid
if [ -f "$PIDFILE" ]; then
  OLD=$(cat "$PIDFILE" 2>/dev/null)
  if [ -n "$OLD" ] && [ "$OLD" != "$$" ] && kill -0 "$OLD" 2>/dev/null; then
    pkill -P "$OLD" 2>/dev/null
    kill "$OLD" 2>/dev/null
  fi
fi
echo $$ >"$PIDFILE"

CFG=$(mktemp /tmp/eww-cava.XXXXXX.conf)
cat >"$CFG" <<EOF
[general]
mode = normal
framerate = 30
autosens = 1
bars = $BARS

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 100
channels = mono
mono_option = average

[smoothing]
noise_reduction = 20
EOF

# cava se identifica por su config temporal, que es única por invocación. Matarlo
# por PID no sirve: vive dentro de un `{ cava | while } &`, así que $! es el PID del
# subshell y cava es un NIETO — al morir el subshell se reparenta a systemd y sigue
# comiendo CPU. Cazado en vivo el 27-jul-2026 con el player en pausa.
kill_cava() { pkill -f "cava -p $CFG" 2>/dev/null; }

cleanup() {
  # solo borrar el pidfile si sigue siendo nuestro
  [ "$(cat "$PIDFILE" 2>/dev/null)" = "$$" ] && rm -f "$PIDFILE"
  kill_cava
  [ -n "$CAVA_PID" ] && kill "$CAVA_PID" 2>/dev/null
  pkill -P $$ 2>/dev/null
  rm -f "$CFG"
}
trap cleanup EXIT INT TERM

start_cava() {
  # Verificar que el proceso siga VIVO, no solo que la variable tenga valor: si
  # cava muere solo (crash, o el sink se va), CAVA_PID queda seteado y sin este
  # chequeo el script no lo revive nunca — quedaría en ceros hasta el próximo
  # cambio de estado del player.
  if [ -n "$CAVA_PID" ] && kill -0 "$CAVA_PID" 2>/dev/null; then
    return
  fi
  CAVA_PID=""
  # cava saca "12;40;8;...;" → lo convertimos a [12,40,8,...]
  {
    cava -p "$CFG" 2>/dev/null | while IFS= read -r line; do
      printf '[%s]\n' "$(printf '%s' "${line%;}" | tr ';' ',')"
    done
  } &
  CAVA_PID=$!
}

stop_cava() {
  kill_cava
  if [ -n "$CAVA_PID" ]; then
    kill "$CAVA_PID" 2>/dev/null
    wait "$CAVA_PID" 2>/dev/null
    CAVA_PID=""
  fi
  echo "$ZEROS"
}

echo "$ZEROS"

# OJO: process substitution, NO `playerctl ... | while`. Con un pipe el while corre
# en un subshell y CAVA_PID no lo ve el trap de arriba → al morir este script cava
# quedaría huérfano comiendo CPU, que es justo lo que queremos evitar.
while IFS= read -r st; do
  case "$st" in
  Playing) start_cava ;;
  *) stop_cava ;;
  esac
done < <(playerctl --follow status 2>/dev/null)
