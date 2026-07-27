-- ╔════════════════════════════════════════════════╗
-- ║              KEYBINDINGS (binds.lua)            ║
-- ╚════════════════════════════════════════════════╝
-- Traducción literal de binds.conf. Dos cambios de forma respecto a hyprlang:
--   * las teclas van en UN string con " + ": "SUPER + SHIFT + Return"
--   * los dispatchers son funciones tipadas de hl.dsp.*, y se pasan LLAMADAS
-- Los comandos con comillas dobles van en [[ ]] para no escaparlas.

-- --- VARIABLES PRINCIPALES --- (eran $vars de hyprlang)
local terminal       = "foot"
local float_terminal = "foot --app-id=foot_float"
local FM2            = "foot --app-id=foot_float yazi"
local fileManager    = "thunar"
local browser        = "firefox"
local menu           = "rofi -show drun -theme ~/.config/rofi/config.rasi"
local wallselect     = "~/.config/rofi/wallselect/script.sh"
local clipboard      = "~/.config/hypr/scripts/cliphist_fuzzel.sh"
local wifi           = "~/.config/rofi/wifi/wifi_manager.sh"

-- --- APLICACIONES Y MENÚS ---
hl.bind("SUPER + Return",         hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd(float_terminal))
hl.bind("SUPER + B",              hl.dsp.exec_cmd(browser))
hl.bind("SUPER + E",              hl.dsp.exec_cmd(FM2))
hl.bind("SUPER + SHIFT + E",      hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + M",              hl.dsp.exec_cmd("~/.config/hypr/scripts/spotify-toggle.sh"))
hl.bind("SUPER + T",              hl.dsp.exec_cmd("Telegram"))
hl.bind("SUPER + Space",          hl.dsp.exec_cmd(menu))
hl.bind("SUPER + W",              hl.dsp.exec_cmd(wallselect))
hl.bind("SUPER + SHIFT + W",      hl.dsp.exec_cmd("~/.config/hypr/scripts/wallhaven-fetch.sh"))  -- Descargar wallpapers de wallhaven
hl.bind("SUPER + C",              hl.dsp.exec_cmd(clipboard))
hl.bind("SUPER + L",              hl.dsp.exec_cmd("~/.config/hypr/scripts/lock.sh"))             -- Lockscreen con viñeta Deep Ocean
hl.bind("SUPER + A",              hl.dsp.exec_cmd(wifi))
hl.bind("SUPER + K",              hl.dsp.exec_cmd("~/.config/hypr/scripts/keybinds-viewer.sh"))  -- Cheatsheet de keybinds (rofi)

-- Activar a Astro por voz: escribe al FIFO que Astro lee (modo ASTRO_INPUT=hotkey). El `[ -p ]` escribe
-- SOLO si el FIFO existe (= Astro corriendo, que lo crea/borra) → si está apagado no crea un archivo
-- basura que rompería el próximo arranque. El timeout 0.3 es red por si Astro murió sucio (FIFO sin lector).
hl.bind("SUPER + SHIFT + A", hl.dsp.exec_cmd([[[ -p /tmp/astro-trigger.fifo ] && timeout 0.3 bash -c 'echo go > /tmp/astro-trigger.fifo']]))

-- Reload de waybar (config + style). Usar tras editar style.css o config.jsonc.
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("pkill -SIGUSR2 waybar"))

-- --- GESTIÓN DE VENTANAS Y SISTEMA ---
hl.bind("SUPER + Q",         hl.dsp.window.close())
hl.bind("SUPER + SHIFT + M", hl.dsp.exit())
hl.bind("SUPER + F",         hl.dsp.window.fullscreen())
hl.bind("SUPER + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + P",         hl.dsp.window.pseudo())
hl.bind("SUPER + D",         hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_float.sh"))
hl.bind("SUPER + CTRL + N",  hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-nightlight.sh"))     -- Night light toggle (hyprsunset)
hl.bind("SUPER + grave",     hl.dsp.exec_cmd("~/.config/hypr/scripts/hub-toggle.sh"))            -- Hub dashboard (grave = `)

-- --- DWINDLE LAYOUT ---
-- togglesplit en 0.54+ va vía layoutmsg (ya no es dispatcher directo).
-- El 3er campo de `bindd =` era la descripción; en Lua va en las opciones.
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"), { description = "Alternar split horizontal/vertical" })
hl.bind("SUPER + H", hl.dsp.layout("swapsplit"),   { description = "Intercambiar ventanas del split actual" })
hl.bind("SUPER + O", hl.dsp.layout("movetoroot"),  { description = "Promover ventana a nodo raiz" })

-- --- NOTIFICACIONES ---
-- DND toggle: activa/desactiva modo silencioso en mako + notif de feedback.
hl.bind("SUPER + N",         hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-dnd.sh"))
-- Dismiss all: limpia todas las notificaciones visibles en pantalla.
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("makoctl dismiss --all"))

-- --- POWER PROFILE ---
-- Cicla entre balanced y performance vía powerprofilesctl.
hl.bind("SUPER + CTRL + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle-power-profile.sh"))

-- --- EL SCRATCHPAD (Terminal Oculta) ---
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind("SUPER + S",         hl.dsp.workspace.toggle_special("magic"))

-- --- MOVIMIENTO DE FOCO (Flechas) ---
hl.bind("SUPER + left",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down",  hl.dsp.focus({ direction = "down" }))

-- --- MOVER VENTANA ENTRE MONITORES ---
-- Tira la ventana enfocada al otro monitor (+1 = siguiente monitor).
hl.bind("SUPER + SHIFT + Tab", hl.dsp.window.move({ monitor = "+1" }))

-- --- MOVER VENTANA EN EL WORKSPACE ACTUAL ---
hl.bind("SUPER + SHIFT + left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind("SUPER + SHIFT + up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind("SUPER + SHIFT + down",  hl.dsp.window.swap({ direction = "down" }))

-- --- MODO REDIMENSIONAR (Submap) ---
-- SUPER+R entra, flechas ajustan, Escape sale.
-- OJO: no unificar la tecla de entrada con la de salida — hay un bug conocido
-- (#14733) donde la misma combinación no resetea desde adentro del submap.
hl.bind("SUPER + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    hl.bind("right", hl.dsp.window.resize({ x = 30,  y = 0,   relative = true }), { repeating = true })
    hl.bind("left",  hl.dsp.window.resize({ x = -30, y = 0,   relative = true }), { repeating = true })
    hl.bind("up",    hl.dsp.window.resize({ x = 0,   y = -30, relative = true }), { repeating = true })
    hl.bind("down",  hl.dsp.window.resize({ x = 0,   y = 30,  relative = true }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- Submap MOVE: mover ventana flotante con flechas (espejo del resize).
-- SUPER+G entra; flechas mueven 30px; SHIFT+flecha mueve 120px (paso grande); Esc sale.
-- `moveactive` solo afecta a ventanas flotantes (foot_float, satty, blueman, pavucontrol).
-- Para tiled, seguí usando SUPER+SHIFT+flecha (swap).
hl.bind("SUPER + G", hl.dsp.submap("move"))

hl.define_submap("move", function()
    hl.bind("right", hl.dsp.window.move({ x = 30,  y = 0,   relative = true }), { repeating = true })
    hl.bind("left",  hl.dsp.window.move({ x = -30, y = 0,   relative = true }), { repeating = true })
    hl.bind("up",    hl.dsp.window.move({ x = 0,   y = -30, relative = true }), { repeating = true })
    hl.bind("down",  hl.dsp.window.move({ x = 0,   y = 30,  relative = true }), { repeating = true })

    hl.bind("SHIFT + right", hl.dsp.window.move({ x = 120,  y = 0,    relative = true }), { repeating = true })
    hl.bind("SHIFT + left",  hl.dsp.window.move({ x = -120, y = 0,    relative = true }), { repeating = true })
    hl.bind("SHIFT + up",    hl.dsp.window.move({ x = 0,    y = -120, relative = true }), { repeating = true })
    hl.bind("SHIFT + down",  hl.dsp.window.move({ x = 0,    y = 120,  relative = true }), { repeating = true })

    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- --- WORKSPACES (Escritorios Virtuales) ---
-- 20 binds mecánicos colapsados en un loop: mismo resultado, intención más clara.
-- i % 10 mapea el workspace 10 a la tecla 0, igual que el .conf.
for i = 1, 10 do
    local key = i % 10
    hl.bind("SUPER + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- --- RATÓN (Mover y Redimensionar con clics) --- (eran bindm)
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- --- HARDWARE (Volumen, Brillo, Multimedia) ---
-- swayosd-client hace la acción Y muestra el OSD. NO encadenar con wpctl:
-- ambos togglean → double-toggle (visible en mute como "luz prende y vuelve").
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise --max-volume 150"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"),                  { repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"))
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"))

hl.bind("xf86audionext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("xf86audioplay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("xf86audioprev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- --- CAPTURAS DE PANTALLA ---
-- 1) Pantalla completa (output) -> clipboard (sin UI, instantáneo)
hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"))

-- 2) Región -> clipboard (sin UI, instantáneo)
--    -b 00000050: dim negro sutil (~31% alpha) en lugar del gris fuerte default.
--    -w 0: sin borde (el default es marco negro 2px).
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd([[grim -g "$(slurp -b 00000050 -w 0)" - | wl-copy]]))

-- 3) Región -> satty (anotar) -> guarda + clipboard
--    --early-exit cierra satty automáticamente al copiar/guardar (Ctrl+Enter en la UI).
hl.bind("SUPER + CTRL + C", hl.dsp.exec_cmd([[sh -c 'dir="$HOME/.local/share/screenshots"; mkdir -p "$dir"; grim -g "$(slurp -b 00000050 -w 0)" - | satty --filename - --output-filename "$dir/$(date +%Y%m%d-%H%M%S)-region.png" --early-exit --copy-command wl-copy']]))
