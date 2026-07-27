#!/usr/bin/env bash
# toggle_float.sh — toggle float/tiled de la ventana activa; al flotar: 1450x800 centrada.

is_floating=$(hyprctl activewindow -j | jq '.floating')

if [ "$is_floating" == "false" ]; then
    hyprctl dispatch 'hl.dsp.window.float({ action = "toggle" })'
    hyprctl dispatch 'hl.dsp.window.resize({ x = 1450, y = 800 })'
    hyprctl dispatch 'hl.dsp.window.center()'
else
    hyprctl dispatch 'hl.dsp.window.float({ action = "toggle" })'
fi
