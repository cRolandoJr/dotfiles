#!/usr/bin/env bash
# Toggle night light vía hyprsunset IPC. Bind: SUPER+CTRL+N
#
# Estados:
#   día   = 6500K (neutral, sin warm shift)
#   noche = 3500K (warm)

set -euo pipefail

current=$(hyprctl hyprsunset temperature 2>/dev/null | head -1)

if [ "$current" -ge 5000 ] 2>/dev/null; then
    hyprctl hyprsunset temperature 3500 >/dev/null
    notify-send -t 1500 -i weather-clear-night "Night light" "On · 3500K"
else
    hyprctl hyprsunset temperature 6500 >/dev/null
    notify-send -t 1500 -i weather-clear "Night light" "Off · 6500K"
fi
