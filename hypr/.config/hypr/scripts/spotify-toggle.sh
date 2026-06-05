#!/usr/bin/env bash
# spotify-toggle.sh — toggle Spotify en special workspace "music".
#
# Si hay una ventana Spotify viva (en hyprctl), togglea el special workspace.
# Si no: lanza Spotify, espera a que la ventana aparezca (la windowrule la
# manda a special:music silent), y dispara el toggle para mostrarla.
#
# Por qué `hyprctl clients` y no `pgrep`: Spotify corre como `.spotify-wrapped`
# en NixOS, así que `pgrep -x spotify` falla. La presencia de la ventana en
# Hyprland es la señal más fiable.

set -euo pipefail

has_spotify_window() {
  hyprctl clients -j 2>/dev/null | grep -qE '"class":\s*"[Ss]potify"'
}

if has_spotify_window; then
  hyprctl dispatch togglespecialworkspace music
  exit 0
fi

# No hay ventana: lanzar y esperar hasta 6s a que aparezca.
spotify --disable-gpu >/dev/null 2>&1 &
disown

for _ in {1..30}; do
  sleep 0.2
  if has_spotify_window; then
    hyprctl dispatch togglespecialworkspace music
    exit 0
  fi
done

# Si después de 6s no apareció, no hago nada (probablemente Spotify falló).
notify-send -u low -t 2000 "Spotify" "No se detectó la ventana tras 6s"
