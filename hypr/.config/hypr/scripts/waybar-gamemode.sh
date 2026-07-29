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

# `is-active` devuelve "inactive" tanto si el unit está parado como si NO EXISTE,
# así que no alcanza para decidir. En la specialisation battery k3s se saca con
# mkForce false y el unit desaparece: ahí el botón no tiene nada que togglear.
state() {
  if [ "$(systemctl is-enabled "$UNIT" 2>/dev/null)" = "not-found" ]; then
    echo absent
  else
    systemctl is-active "$UNIT" 2>/dev/null
  fi
}

emit() {
  case "$(state)" in
    active)
      printf '{"text":"%s","class":"off","tooltip":"Modo juego OFF\\nk3s corriendo — 6.7%% CPU, 539 MiB\\nClick para liberarlo"}\n' "$ICON"
      ;;
    inactive | failed)
      printf '{"text":"%s","class":"on","tooltip":"Modo juego ON\\nk3s parado\\nClick para volver a arrancarlo"}\n' "$ICON"
      ;;
    absent)
      printf '{"text":"%s","class":"absent","tooltip":"Perfil battery activo\\nk3s no existe en esta specialisation — ya no consume\\nVolvé con battery-off"}\n' "$ICON"
      ;;
    *)
      printf '{"text":"%s","class":"busy","tooltip":"k3s en transición…"}\n' "$ICON"
      ;;
  esac
}

case "${1:-status}" in
  toggle)
    if [ "$(state)" = absent ]; then
      notify-send -u low -a "Modo juego" "Perfil battery activo" \
        "k3s no existe en esta specialisation. Volvé con battery-off."
      exit 0
    fi
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
