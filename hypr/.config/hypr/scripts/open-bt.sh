#!/usr/bin/env bash
# blueman-manager en el workspace activo del monitor enfocado
ws=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused) | .activeWorkspace.id')
hyprctl dispatch exec "[workspace ${ws:-1}] blueman-manager"
