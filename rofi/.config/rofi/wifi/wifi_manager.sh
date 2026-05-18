#!/usr/bin/env bash
set -euo pipefail

export PS4='+ ${LINENO}: '
LOG=/tmp/wifi-run.log
CHOICE_LOG=/tmp/rofi-wifi-choice
: >"$LOG"
: >"$CHOICE_LOG"

log() { printf '%s %s\n' "$(date '+%H:%M:%S')" "$*" | tee -a "$LOG"; }

# Themes (ajusta si hace falta)
LIST_THEME="$HOME/.config/rofi/wifi/list.rasi"
ENABLE_THEME="$HOME/.config/rofi/wifi/enable.rasi"
SSID_THEME="$HOME/.config/rofi/wifi/ssid.rasi"
PASSWORD_THEME="$HOME/.config/rofi/wifi/password.rasi"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 127; }; }
need nmcli
need rofi
need awk
need sort
need sed

notify() { notify-send -t 3000 -i network-wireless "$@"; }

log "Starting wifi script"
log "ENV: XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-<unset>}"
log "ENV: WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-<unset>}"
log "ENV: DBUS_SESSION_BUS_ADDRESS=${DBUS_SESSION_BUS_ADDRESS:-<unset>}"

log "Notify test (non-fatal)"
if ! timeout 2 notify-send "Wi‑Fi script starting" >/dev/null 2>&1; then
  log "notify-send failed or timed out (ignored)"
fi

theme_arg() {
  local f="$1"
  if [[ -n "$f" && -f "$f" ]]; then
    printf -- "-theme %s" "$f"
  else
    printf ''
  fi
}

enable_wifi_menu() {
  local ta; ta=$(theme_arg "$ENABLE_THEME")
  # shellcheck disable=SC2086
  rofi -dmenu -p "Wi‑Fi is off" $ta
}

list_wifi_menu() {
  local ta; ta=$(theme_arg "$LIST_THEME")
  {
    printf "%s\n" "   Disable Wi‑Fi"
    printf "%s\n" "   Manual Setup"
    [[ -n "${connection_status:-}" ]] && printf "%s\n" "$connection_status"
    printf "%s\n" "────────── Redes ──────────"
    printf "%s\n" "${wifi_list}"
  } | (
    # shellcheck disable=SC2086
    rofi -markup-rows -dmenu $ta
  )
}

prompt_ssid() {
  local ta; ta=$(theme_arg "$SSID_THEME")
  # shellcheck disable=SC2086
  rofi -dmenu -p "SSID" $ta
}

prompt_password() {
  local ta; ta=$(theme_arg "$PASSWORD_THEME")
  # shellcheck disable=SC2086
  rofi -dmenu -password -p "Password" $ta
}

# --- Saved connections helpers ---
# Devuelve el nombre del perfil wifi guardado cuyo SSID == $1 (si existe)
saved_connection_name_for_ssid() {
  local ssid="$1"
  # Nota: `connection show` lista perfiles; consultamos cada perfil wifi y leemos 802-11-wireless.ssid
  nmcli -t -f NAME,TYPE connection show \
    | awk -F: '$2=="802-11-wireless"{print $1}' \
    | while IFS= read -r name; do
        [[ -z "$name" ]] && continue
        prof_ssid="$(nmcli -g 802-11-wireless.ssid connection show "$name" 2>/dev/null || true)"
        if [[ "$prof_ssid" == "$ssid" ]]; then
          printf '%s\n' "$name"
          exit 0
        fi
      done
}

has_saved_connection_for_ssid() {
  local ssid="$1"
  [[ -n "$(saved_connection_name_for_ssid "$ssid")" ]]
}

connect_without_prompt() {
  local ssid="$1"

  # 1) Preferir levantar el perfil guardado (si existe)
  if conn="$(saved_connection_name_for_ssid "$ssid")" && [[ -n "${conn:-}" ]]; then
    nmcli -w 12 connection up "$conn" && return 0
    # si falla, seguimos a intentar directo por SSID
  fi

  # 2) Intentar conectar por SSID sin password (open o secrets ya guardados)
  out="$(nmcli -w 12 device wifi connect "$ssid" 2>&1)" && return 0

  # 3) Detectar caso "necesita clave"
  if grep -qiE "secrets were required|need.*secrets|password.*required|No secrets|not provided" <<<"$out"; then
    echo "$out" >>"$LOG"
    return 10
  fi

  echo "$out" >>"$LOG"
  return 1
}

# MAIN
wifi_status="$(nmcli -t -f WIFI general | tail -n1 | tr -d '\r\n' || true)"
log "wifi_status='$wifi_status'"

if [[ "$wifi_status" == "disabled" ]]; then
  log "Wi‑Fi disabled, asking to enable..."
  choice=$(enable_wifi_menu) || choice=""
  log "enable menu returned rc=$? choice='$choice'"
  if [[ -n "$choice" ]]; then
    nmcli radio wifi on
    sleep 1
  else
    log "User cancelled enable menu, exiting"
    exit 0
  fi
fi

nmcli device wifi rescan >/dev/null 2>&1 || log "nmcli rescan failed"
sleep 0.6

connected_ssid="$(nmcli -t -f active,ssid dev wifi | awk -F: '$1=="yes"{print $2; exit}' || true)"
if [[ -n "$connected_ssid" ]]; then
  connection_status="   Connected to ${connected_ssid}"
else
  connection_status=""
fi

# Build wifi list
wifi_list=$(
  nmcli -t -f SIGNAL,BARS,SSID,SECURITY dev wifi list 2>/dev/null \
  | sort -rn \
  | awk -F: '
  {
    sig=$1; bars=$2; ssid=$3; sec=$4;

    if (ssid == "" || seen[ssid]++) next;

    lock = (sec ~ /WPA|WEP|802\.1X/) ? "" : "";
    printf "%s  %s  %s :::%s\n", bars, lock, ssid, ssid
  }' \
  | while IFS= read -r line; do
      ssid="${line##*:::}"
      if nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="802-11-wireless"{print $1}' \
        | while IFS= read -r name; do
            prof_ssid="$(nmcli -g 802-11-wireless.ssid connection show "$name" 2>/dev/null || true)"
            [[ "$prof_ssid" == "$ssid" ]] && exit 0
          done
      then
        printf "󰌾  %s\n" "$line"   # saved
      else
        printf "   %s\n" "$line"
      fi
    done
)

log "Prepared wifi_list (first 20 lines):"
printf '%s\n' "$wifi_list" | sed -n '1,20p' | tee -a "$LOG"

choice="$(list_wifi_menu)"
rofi_rc=$?
printf '%s\n' "choice='$choice'" > "$CHOICE_LOG"
printf '%s\n' "rofi_rc=$rofi_rc" >> "$CHOICE_LOG"
log "Rofi rc=$rofi_rc choice='${choice}' (also saved to $CHOICE_LOG)"

if [[ $rofi_rc -ne 0 ]]; then
  log "Rofi cancelled or failed (rc=$rofi_rc); exiting"
  exit 0
fi

# Trim
choice="${choice#"${choice%%[![:space:]]*}"}"
choice="${choice%"${choice##*[![:space:]]}"}"

case "$choice" in
  *"Disable Wi‑Fi"*|"*Disable Wi-Fi"*)
    nmcli radio wifi off
    notify "Wi‑Fi disabled"
    ;;
  *"Manual Setup"*)
    ssid=$(prompt_ssid) || ssid=""
    [[ -z "$ssid" ]] && exit 0
    password=$(prompt_password) || password=""
    if [[ -n "$password" ]]; then
      nmcli dev wifi connect "$ssid" password "$password"
    else
      nmcli dev wifi connect "$ssid" hidden yes
    fi
    ;;
  *"Connected to "* )
    conn_name="$(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2=="802-11-wireless"{print $1; exit}' || true)"
    if [[ -n "$conn_name" ]]; then
      if command -v kitty >/dev/null 2>&1; then
        kitty -e sh -c "nmcli connection show \"$conn_name\"; echo; read -p 'Press Return to close...'"
      else
        nmcli connection show "$conn_name" | less
      fi
    else
      notify "No active Wi‑Fi connection found"
    fi
    ;;
  *)
    if [[ "$choice" == *":::"* ]]; then
      ssid="${choice##*:::}"
    else
      ssid="$(echo "$choice" | sed -E 's/^[^[:alnum:]]+//')"
    fi
    [[ -z "$ssid" ]] && exit 0

    # Try connect without password prompt
    if connect_without_prompt "$ssid"; then
      notify "Connected" "$ssid"
      log "Connected to '$ssid' without prompting for password."
      exit 0
    fi

    rc=$?
    if [[ $rc -ne 10 ]]; then
      notify "Wi‑Fi error" "Failed to connect to $ssid"
      log "Failed to connect to '$ssid' (rc=$rc)."
      exit 1
    fi

    # Need secrets: ask password once, then connect
    password=$(prompt_password) || password=""
    [[ -z "$password" ]] && exit 0
    nmcli -w 12 device wifi connect "$ssid" password "$password"
    notify "Connected" "$ssid"
    ;;
esac

log "Done."
