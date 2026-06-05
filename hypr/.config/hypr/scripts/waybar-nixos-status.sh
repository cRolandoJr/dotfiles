#!/usr/bin/env bash
# waybar-nixos-status.sh — JSON output para custom/nixos.
# Muestra:  <gen> 󰎃    (símbolo NixOS coloreado: rojo dirty / verde clean)
# Tooltip:  versión, kernel, status del flake, fecha rebuild.

set -euo pipefail

ICON=$''   # nf-linux-nixos (símbolo NixOS NerdFont)
FLAKE_DIR="$HOME/projects/nix-config"

# Generation actual del system profile (sin sudo).
GEN=$(basename "$(readlink /nix/var/nix/profiles/system 2>/dev/null)" | grep -oE '[0-9]+' || echo "?")

# Versión NixOS major.minor (e.g. "26.05").
VER=$(cut -d. -f1-2 /run/current-system/nixos-version 2>/dev/null || echo "?")

KERNEL=$(uname -r)

# Última rebuild — sin segundos para que entre en una línea.
LAST=$(stat -c '%y' /nix/var/nix/profiles/system 2>/dev/null | cut -d: -f1-2)

# Estado del flake (git porcelain).
DIRTY_COUNT=0
FLAKE_LABEL="clean"
if [ -d "$FLAKE_DIR/.git" ]; then
  DIRTY_COUNT=$(git -C "$FLAKE_DIR" status --porcelain 2>/dev/null | wc -l)
  if [ "$DIRTY_COUNT" -gt 0 ]; then
    FLAKE_LABEL="dirty ($DIRTY_COUNT archivos)"
  fi
fi

if [ "$DIRTY_COUNT" -eq 0 ]; then
  ICON_COLOR="#3b82f6"   # azul NixOS oficial
  CLASS="clean"
else
  ICON_COLOR="#f87171"   # rojo Deep Ocean
  CLASS="dirty"
fi

TEXT="<span color='$ICON_COLOR' size='large'>$ICON</span> $GEN"
TOOLTIP="NixOS $VER\nGen $GEN | Kernel $KERNEL\nFlake: $FLAKE_LABEL\nRebuild: $LAST"

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$TEXT" "$TOOLTIP" "$CLASS"
