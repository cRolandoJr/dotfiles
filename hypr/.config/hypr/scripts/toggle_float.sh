#!/bin/bash

# Obtener el estado flotante de la ventana activa
is_floating=$(hyprctl activewindow -j | jq '.floating')

if [ "$is_floating" == "false" ]; then
    # Si NO está flotando: Hazla flotar, cambia el tamaño y céntrala
    hyprctl dispatch togglefloating
    hyprctl dispatch resizeactive exact 1450 800 
    hyprctl dispatch centerwindow
else
    # Si YA está flotando: Simplemente devuélvela al modo Tiled
    hyprctl dispatch togglefloating
fi
