#!/usr/bin/env bash
# Streaming JSON para módulo custom/layout de waybar.
# Emite "US" / "ES" según el active_keymap del teclado principal.
# Se suscribe al socket de eventos Hyprland → cero polling.
#
# Robustez contra race condition al boot:
#   - NO usa `set -e` (un fallo transitorio de hyprctl no debe matar el daemon).
#   - Espera activamente a que HYPRLAND_INSTANCE_SIGNATURE esté seteada
#     y el socket de eventos exista.
#   - Si hyprctl no devuelve un layout válido al inicio, emite "??" y sigue —
#     el primer evento activelayout sobreescribirá ese estado.

emit() {
  case "$1" in
    *English*)
      printf '{"text":"US","class":"us","tooltip":"%s"}\n' "$1"
      ;;
    *Latin*|*Spanish*)
      printf '{"text":"ES","class":"es","tooltip":"%s"}\n' "$1"
      ;;
    *)
      short=$(printf '%s' "${1:0:2}" | tr '[:lower:]' '[:upper:]')
      [ -z "$short" ] && short="??"
      printf '{"text":"%s","class":"unknown","tooltip":"%s"}\n' "$short" "$1"
      ;;
  esac
}

# Esperar hasta 10s a que Hyprland setee su instancia + socket
for _ in 1 2 3 4 5 6 7 8 9 10; do
  if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] \
     && [ -S "${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" ]; then
    break
  fi
  sleep 1
done

SOCKET="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

# Estado inicial — tolerante a que hyprctl/jq fallen al boot
current=$(hyprctl devices -j 2>/dev/null \
  | jq -r '.keyboards[]? | select(.main == true) | .active_keymap' 2>/dev/null \
  | head -n1)
emit "${current:-Unknown}"

# Stream de cambios. Si socat muere por cualquier razón, el script termina y waybar
# reintenta gracias a `restart-interval` del módulo.
socat -U - "UNIX-CONNECT:${SOCKET}" 2>/dev/null | while IFS= read -r line; do
  case "$line" in
    activelayout\>\>*)
      layout="${line#*,}"
      emit "$layout"
      ;;
  esac
done
