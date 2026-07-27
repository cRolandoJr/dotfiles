#!/usr/bin/env bash
# Uso, VRAM y temperatura de la GPU dedicada. Sale como JSON para el defpoll gpu.
#
# eww no tiene variable mágica de GPU. Los datos vienen de sysfs de amdgpu.
#
# Esta máquina es híbrida muxless: RX 6500M (dGPU, 4 GiB dedicados) + Radeon 680M
# (iGPU, VRAM compartida). El número de `card` puede cambiar entre boots, así que
# la dGPU se identifica por tener el vram_total más grande en vez de hardcodear
# card1.

set -uo pipefail

BEST_DIR=""
BEST_TOTAL=0

for d in /sys/class/drm/card*/device; do
  [ -r "$d/mem_info_vram_total" ] || continue
  t=$(cat "$d/mem_info_vram_total" 2>/dev/null) || continue
  [ -z "$t" ] && continue
  if [ "$t" -gt "$BEST_TOTAL" ]; then
    BEST_TOTAL=$t
    BEST_DIR=$d
  fi
done

[ -z "$BEST_DIR" ] && {
  echo '{"busy":0,"vram_used":0,"vram_total":0,"temp":"0"}'
  exit 0
}

busy=$(cat "$BEST_DIR/gpu_busy_percent" 2>/dev/null || echo 0)
used=$(cat "$BEST_DIR/mem_info_vram_used" 2>/dev/null || echo 0)

# hwmon expone la temperatura del borde del die en milésimas de grado
temp=0
for h in "$BEST_DIR"/hwmon/hwmon*/temp1_input; do
  [ -r "$h" ] || continue
  raw=$(cat "$h" 2>/dev/null) || continue
  temp=$((raw / 1000))
  break
done

jq -n --argjson b "${busy:-0}" --argjson u "$((used / 1048576))" \
  --argjson t "$((BEST_TOTAL / 1048576))" --argjson tc "${temp:-0}" \
  '{busy:$b,vram_used:$u,vram_total:$t,temp:$tc}'
