-- UWSM importa el environment al systemd user manager (DBus incluido), así que
-- dbus-update-activation-environment ya no es necesario. Cada app larga vida
-- corre con `uwsm app --` → su propio systemd scope (logs, OOM y cleanup por app).
--
-- Los `exec-once` de hyprlang pasan a un único handler del evento hyprland.start.
-- Si algún día hace falta algo que se re-ejecute en cada reload (el viejo `exec =`),
-- eso va en hl.on("config.reloaded", ...), que es un evento distinto.
-- El `~` se expande (verificado en 0.56), así que las rutas van literales.

hl.on("hyprland.start", function()
    -- waybar: NO se lanza aquí. Va como servicio de usuario
    -- (programs.waybar.systemd.enable) porque 0.15.0 crashea al perder el audio
    -- y con exec_cmd nadie lo relevanta. El TZ del reloj va en el unit.

    -- Widgets custom (calendar popup; ver ~/.config/eww/eww.yuck)
    -- Se invoca desde waybar con `eww open --toggle calendar` (on-click del clock).
    hl.exec_cmd("uwsm app -- eww daemon")
    -- Trigger inicial del defpoll `weather`: eww no corre el primer poll cuando
    -- :initial está seteado. Espera al daemon y dispara una vez.
    hl.exec_cmd("uwsm app -- bash -c 'until eww ping >/dev/null 2>&1; do sleep 0.2; done; eww poll weather'")

    -- mako: NO se lanza aquí. El paquete provee mako.service (Type=dbus,
    -- BusName=org.freedesktop.Notifications) que arranca on-demand cuando
    -- llega la primera notif. Lanzarlo dos veces (uwsm + dbus-activation)
    -- generaba conflicto de BusName.
    hl.exec_cmd("uwsm app -- awww-daemon")
    -- Wallpaper: restaura el último seleccionado vía wallselect (SUPER+W).
    hl.exec_cmd("uwsm app -- bash -c 'until awww query >/dev/null 2>&1; do sleep 0.2; done; awww restore'")

    -- OSD
    hl.exec_cmd("uwsm app -- swayosd-server")

    -- Screen lock / idle
    hl.exec_cmd("uwsm app -- hypridle -c ~/.config/hypr/hypridle.conf")

    -- Clipboard history (texto e imágenes)
    hl.exec_cmd("uwsm app -- wl-paste --watch cliphist store")
    hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")
end)

-- Nota: la notificación de cambio de layout (notify-layout.sh) ahora corre
-- como systemd user service (notify-layout.service), definido en la
-- nix-config (modules/desktop-hyprland.nix).
