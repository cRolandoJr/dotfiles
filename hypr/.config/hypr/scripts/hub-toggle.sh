#!/usr/bin/env bash
# Toggle del hub eww en el monitor enfocado (multi-monitor).
mon=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused) | .id')
if eww active-windows 2>/dev/null | grep -q '^hub:'; then
  eww close hub
else
  eww open hub --screen "${mon:-0}"
fi
