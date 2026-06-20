#!/usr/bin/env bash
# Streaming JSON para módulo custom/wscount de waybar.
# Emite la cantidad de ventanas del workspace activo (el "tape" en scrolling).
# Se suscribe al socket de eventos Hyprland → cero polling.
#
# Misma robustez que waybar-layout.sh: sin `set -e`, espera al socket al boot,
# y waybar reintenta vía restart-interval si el lector muere.
# Usa `ncat -U` (no socat): socat no está en el PATH del usuario, ncat sí.

emit() {
  count=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.windows // 0' 2>/dev/null)
  [ -z "$count" ] && count=0
  printf '{"text":" %s","tooltip":"%s ventana(s) en este workspace","class":"n%s"}\n' \
    "$count" "$count" "$count"
}

# Esperar hasta 10s a que Hyprland setee su instancia + socket de eventos
for _ in 1 2 3 4 5 6 7 8 9 10; do
  if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] \
     && [ -S "${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" ]; then
    break
  fi
  sleep 1
done

SOCKET="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

# Estado inicial
emit

# Stream de cambios: cualquier evento que altere el conteo del ws activo.
ncat -U "${SOCKET}" 2>/dev/null | while IFS= read -r line; do
  case "$line" in
    workspace\>\>*|openwindow\>\>*|closewindow\>\>*|movewindow*\>\>*|focusedmon\>\>*|activespecial\>\>*)
      emit
      ;;
  esac
done
