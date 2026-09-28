#!/usr/bin/env bash
# Toggle del hub eww en el monitor enfocado (multi-monitor).
mon=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused) | .id')
if eww active-windows 2>/dev/null | grep -q '^hub:'; then
  eww close hub
else
  # Sin --no-daemonize, un daemon lento (>100 ms al ping) hace que open levante otro y le robe el socket.
  eww --no-daemonize open hub --screen "${mon:-0}"
fi
