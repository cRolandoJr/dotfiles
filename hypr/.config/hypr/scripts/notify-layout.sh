#!/usr/bin/env bash
# Daemon: escucha el socket de eventos de Hyprland y notifica al cambiar layout.
# Funciona independientemente de cómo se haya disparado el cambio (xkb grp:alt_shift_toggle,
# hyprctl switchxkblayout, click en widget de waybar, etc).
# Se lanza desde configs/autostart.conf con exec-once.

set -euo pipefail

SOCKET="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

exec socat -U - "UNIX-CONNECT:${SOCKET}" | while IFS= read -r line; do
  case "$line" in
    activelayout\>\>*)
      # Formato del evento: activelayout>>device_name,layout_name
      layout="${line#*,}"
      notify-send \
        -t 1500 \
        -h string:x-canonical-private-synchronous:layout \
        "⌨  Layout" "$layout"
      ;;
  esac
done
