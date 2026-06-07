#!/usr/bin/env bash
# lock.sh — Lanza hyprlock con shader de viñeta Deep Ocean
#
# Flujo:
#   1. Activa el screen_shader de Hyprland (viñeta sobre toda la pantalla)
#   2. Lanza hyprlock y espera a que termine (bloquea hasta que el user debloquea)
#   3. Desactiva el screen_shader volviendo a "" (sin shader)
#
# Por qué este approach y no un shader dentro de hyprlock:
#   - hyprlock v0.9.5 no tiene opción "screen_shader" propia; sus shaders son internos.
#   - decoration:screen_shader es una feature del compositor Hyprland que aplica
#     un GLSL a todo el frame de pantalla antes de enviarlo al display.
#   - Al activarlo antes de hyprlock y desactivarlo después, el efecto es limpio:
#     la viñeta aparece con el lockscreen y desaparece al desbloquear.
#
# Dependencias: hyprctl, hyprlock (ambos en PATH en una sesión Hyprland normal)

SHADER="$HOME/.config/hypr/shaders/lock-vignette.glsl"

# Verificar que el shader existe antes de activar
if [[ ! -f "$SHADER" ]]; then
    echo "lock.sh: shader no encontrado en $SHADER, bloqueando sin shader" >&2
    exec hyprlock
fi

# Activar viñeta
hyprctl keyword decoration:screen_shader "$SHADER"

# Bloquear — hyprlock bloquea la ejecución hasta que el user se autentique
hyprlock

# Desactivar viñeta (restaurar a sin shader)
hyprctl keyword decoration:screen_shader ""
