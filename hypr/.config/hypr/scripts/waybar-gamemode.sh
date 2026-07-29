#!/usr/bin/env bash
# Modo juego: para los dos daemons always-on que gastan sin que los uses.
#
#   k3s  — 6.7% de CPU y 539 MiB en idle (medido 29-jul-2026)
#   scx  — scx_lavd gasta CPU a propósito para bajar latencia; sin cargador es
#          justo lo contrario de lo que querés
#
# Reemplaza a la specialisation `battery`, que hacía exactamente esto con dos
# `mkForce false` pero costaba build en cada rebuild y una entrada de boot por
# generación (45 acumuladas) — y bootear ahí por accidente dejaba el botón sin
# unit que togglear.
#
# NO toca el perfil de energía: gamemode ya pone el governor en performance por
# juego, y `powerprofilesctl set` necesita un agente polkit que un click no tiene.
#
# El estado se DERIVA de systemctl, no de un archivo de flag: así el botón no
# puede quedar desincronizado si algo arranca o se para por otra vía.
#
# El sudo es NOPASSWD acotado a los comandos exactos (ver base.nix).

UNITS=(k3s.service scx.service)
SYSTEMCTL=/run/current-system/sw/bin/systemctl
ICON='󰊴'

# `is-active` devuelve "inactive" tanto si el unit está parado como si NO EXISTE,
# así que no alcanza para decidir. `is-enabled` sí distingue (da "not-found").
exists() { [ "$(systemctl is-enabled "$1" 2>/dev/null)" != "not-found" ]; }

# Estado del conjunto: si alguno corre, el modo juego está OFF.
state() {
  local any_exists=0 any_active=0 u
  for u in "${UNITS[@]}"; do
    exists "$u" || continue
    any_exists=1
    [ "$(systemctl is-active "$u" 2>/dev/null)" = active ] && any_active=1
  done
  if [ "$any_exists" = 0 ]; then
    echo absent
  elif [ "$any_active" = 1 ]; then
    echo running
  else
    echo stopped
  fi
}

emit() {
  case "$(state)" in
    running)
      printf '{"text":"%s","class":"off","tooltip":"Modo juego OFF\\nk3s + scx corriendo — 6.7%% CPU y 539 MiB de k3s\\nClick para liberarlos"}\n' "$ICON"
      ;;
    stopped)
      printf '{"text":"%s","class":"on","tooltip":"Modo juego ON\\nk3s y scx parados\\nClick para volver a arrancarlos"}\n' "$ICON"
      ;;
    absent)
      printf '{"text":"%s","class":"absent","tooltip":"Ni k3s ni scx están declarados en esta config\\nNada que togglear"}\n' "$ICON"
      ;;
  esac
}

case "${1:-status}" in
  toggle)
    case "$(state)" in
      absent)
        notify-send -u low -a "Modo juego" "Nada que togglear" \
          "Ni k3s ni scx están declarados en esta config."
        exit 0
        ;;
      running) action=stop ;;
      stopped) action=start ;;
    esac

    done_units=()
    for u in "${UNITS[@]}"; do
      exists "$u" || continue
      sudo "$SYSTEMCTL" "$action" "$u" && done_units+=("${u%.service}")
    done

    if [ "$action" = stop ]; then
      notify-send -a "Modo juego" -i input-gaming \
        "Modo juego ON" "Parados: ${done_units[*]:-nada}"
    else
      notify-send -a "Modo juego" -i input-gaming \
        "Modo juego OFF" "De vuelta: ${done_units[*]:-nada}"
    fi
    pkill -RTMIN+11 waybar 2>/dev/null || true
    ;;
  *)
    emit
    ;;
esac
