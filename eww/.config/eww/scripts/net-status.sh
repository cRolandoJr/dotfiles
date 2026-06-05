#!/usr/bin/env bash
# Network status para el hub eww.
# Output JSON: enriquecido con datos para tooltip estilo waybar.
#
# wifi_enabled  bool string
# wifi_ssid     SSID activo
# wifi_signal   % señal (0-100)
# wifi_ip       IP v4
# wifi_freq     GHz (1 decimal)
# bt_powered    bool string
# bt_device     nombre device conectado
# bt_battery    %  (vacío si no soporta)

set -uo pipefail

wifi_enabled="false"
wifi_ssid=""
wifi_signal=""
wifi_ip=""
wifi_freq=""

# ─── WiFi ────────────────────────────────────────────────────────────────────
if command -v nmcli >/dev/null 2>&1; then
    # locale C: en es_AR nmcli devuelve "sí" en vez de "yes"
    wifi_state=$(LC_ALL=C nmcli -t -f WIFI g 2>/dev/null | head -1)
    if [ "$wifi_state" = "enabled" ]; then
        wifi_enabled="true"
        # IN-USE,SSID,SIGNAL,FREQ del active access point en un solo call
        active=$(LC_ALL=C nmcli -t -f IN-USE,SSID,SIGNAL,FREQ dev wifi 2>/dev/null | awk -F: '$1=="*"{print; exit}')
        if [ -n "$active" ]; then
            wifi_ssid=$(echo "$active" | cut -d: -f2)
            wifi_signal=$(echo "$active" | cut -d: -f3)
            wifi_freq_mhz=$(echo "$active" | cut -d: -f4)
            wifi_freq=$(awk -v m="$wifi_freq_mhz" 'BEGIN{printf "%.1f", m/1000}')
            wifi_iface=$(LC_ALL=C nmcli -t -f DEVICE,TYPE device 2>/dev/null | awk -F: '$2=="wifi"{print $1; exit}')
            if [ -n "$wifi_iface" ]; then
                wifi_ip=$(LC_ALL=C nmcli -t -f IP4.ADDRESS device show "$wifi_iface" 2>/dev/null | head -1 | cut -d: -f2 | cut -d/ -f1 | tr -d ' ')
            fi
        fi
    fi
fi

# ─── Bluetooth ───────────────────────────────────────────────────────────────
bt_powered="false"
bt_device=""
bt_battery=""
if command -v bluetoothctl >/dev/null 2>&1; then
    if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
        bt_powered="true"
        bt_line=$(bluetoothctl devices Connected 2>/dev/null | head -1)
        if [ -n "$bt_line" ]; then
            bt_mac=$(echo "$bt_line" | awk '{print $2}')
            bt_device=$(echo "$bt_line" | cut -d' ' -f3-)
            # Battery (no todos los devices reportan; viene en "Battery Percentage: 0xNN (NN)")
            bt_battery=$(bluetoothctl info "$bt_mac" 2>/dev/null | grep -i "Battery Percentage" | grep -oE '\([0-9]+\)' | tr -d '()')
        fi
    fi
fi

jq -n \
    --arg we "$wifi_enabled" \
    --arg ws "$wifi_ssid" \
    --arg wsig "$wifi_signal" \
    --arg wip "$wifi_ip" \
    --arg wfreq "$wifi_freq" \
    --arg bp "$bt_powered" \
    --arg bd "$bt_device" \
    --arg bb "$bt_battery" \
    '{
        wifi_enabled: $we,
        wifi_ssid:    $ws,
        wifi_signal:  $wsig,
        wifi_ip:      $wip,
        wifi_freq:    $wfreq,
        bt_powered:   $bp,
        bt_device:    $bd,
        bt_battery:   $bb
    }'
