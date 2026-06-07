#!/usr/bin/env bash
# toggle_float.sh — toggle float/tiled de la ventana activa; al flotar: 1450x800 centrada.

is_floating=$(hyprctl activewindow -j | jq '.floating')

if [ "$is_floating" == "false" ]; then
    hyprctl dispatch togglefloating
    hyprctl dispatch resizeactive exact 1450 800
    hyprctl dispatch centerwindow
else
    hyprctl dispatch togglefloating
fi
