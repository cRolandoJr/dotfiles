#!/usr/bin/env bash
# Toggle WiFi / Bluetooth on/off. Usado por on-click de eww net-row.
# Uso: net-toggle.sh wifi | bt

case "${1:-}" in
    wifi)
        state=$(nmcli -t -f WIFI g | head -1)
        if [ "$state" = "enabled" ]; then
            nmcli radio wifi off
        else
            nmcli radio wifi on
        fi
        ;;
    bt)
        if bluetoothctl show | grep -q "Powered: yes"; then
            bluetoothctl power off
        else
            bluetoothctl power on
        fi
        ;;
    *)
        echo "uso: $0 wifi|bt" >&2
        exit 1
        ;;
esac
