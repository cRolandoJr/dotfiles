#!/usr/bin/env bash
# Modo juego: para k3s, que en idle come 6.7% de CPU y 539 MiB (medido 28-jul-2026).
#
# NO toca el perfil de energía: gamemode ya pone el governor en performance por
# juego (desiredgov=performance en su config), así que hacerlo acá sería
# redundante — y powerprofilesctl necesita polkit interactivo, que desde un click
# de waybar pediría contraseña.
#
# El estado se DERIVA de systemctl, no de un archivo de flag: así el botón no
# puede quedar desincronizado si k3s arranca o se para por otra vía.
#
# El sudo es NOPASSWD acotado al comando exacto (ver base.nix).

UNIT=k3s.service
SYSTEMCTL=/run/current-system/sw/bin/systemctl
ICON='󰊴'

state() { systemctl is-active "$UNIT" 2>/dev/null; }

emit() {
  case "$(state)" in
    active)
      printf '{"text":"%s","class":"off","tooltip":"Modo juego OFF\\nk3s corriendo — 6.7%% CPU, 539 MiB\\nClick para liberarlo"}\n' "$ICON"
      ;;
    inactive | failed)
      printf '{"text":"%s","class":"on","tooltip":"Modo juego ON\\nk3s parado\\nClick para volver a arrancarlo"}\n' "$ICON"
      ;;
    *)
      printf '{"text":"%s","class":"busy","tooltip":"k3s en transición…"}\n' "$ICON"
      ;;
  esac
}

case "${1:-status}" in
  toggle)
    if [ "$(state)" = active ]; then
      sudo "$SYSTEMCTL" stop "$UNIT" && notify-send -a "Modo juego" -i input-gaming \
        "Modo juego ON" "k3s parado — CPU y RAM liberadas"
    else
      sudo "$SYSTEMCTL" start "$UNIT" && notify-send -a "Modo juego" -i input-gaming \
        "Modo juego OFF" "k3s de vuelta"
    fi
    pkill -RTMIN+11 waybar 2>/dev/null || true
    ;;
  *)
    emit
    ;;
esac
