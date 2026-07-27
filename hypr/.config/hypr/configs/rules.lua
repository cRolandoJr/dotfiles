-- ╔════════════════════════════════════════════════╗
-- ║           WINDOW & LAYER RULES (rules.lua)      ║
-- ╚════════════════════════════════════════════════╝
-- Traducción literal de rules.conf.
--
-- Los regex van con corchetes largos [[...]] cuando contienen backslashes:
-- en un string "..." de Lua, \d y \. serían escapes y la regla dejaría de
-- matchear SIN dar error. Con [[ ]] el contenido es literal.

hl.window_rule({
    name   = "terminal_flotante",
    match  = { class = "^(foot_float)$" },
    float  = true,
    size   = { 1450, 800 },
    center = true,
})

hl.window_rule({
    name     = "fix_xwaylandvideobridge",
    match    = { class = "^(xwaylandvideobridge)$" },
    opacity  = 0.0,
    no_anim  = true,
    no_focus = true,
    max_size = { 1, 1 },
    no_blur  = true,
})

hl.window_rule({
    name   = "center_vscode_dialogs",
    match  = { class = "^(Code)$", title = "^(Visual Studio Code)$" },
    center = true,
})

hl.window_rule({
    name   = "ssh_askpass_float",
    match  = { title = "^(OpenSSH Authentication Passphrase request)$" },
    float  = true,
    size   = { 480, 200 },
    center = true,
})

hl.window_rule({
    name   = "satty_float",
    match  = { class = [[^(com\.gabm\.satty)$]] },
    float  = true,
    size   = { 1280, 720 },
    center = true,
})

hl.window_rule({
    name   = "blueman_float",
    match  = { class = [[^(blueman-manager|\.blueman-manager-wrapped_?)$]] },
    float  = true,
    size   = { 720, 520 },
    center = true,
})

hl.window_rule({
    name   = "pavucontrol_float",
    match  = { class = [[^(\.pavucontrol-wrapped|pavucontrol|org\.pulseaudio\.pavucontrol)$]] },
    float  = true,
    size   = { 720, 520 },
    center = true,
})

hl.window_rule({
    name      = "spotify_scratch",
    match     = { class = "^(Spotify|spotify)$" },
    workspace = "special:music silent",
})

-- Los juegos (Proton/XWayland) recrean su ventana al pasar a fullscreen y
-- caen en el monitor enfocado; anclarlos al HDMI evita tener que moverlos.
hl.window_rule({
    name    = "steam_games_hdmi",
    match   = { class = [[^(steam_app_\d+)$]] },
    monitor = "HDMI-A-1",
})

-- --- REGLAS ANÓNIMAS (eran de una sola línea en hyprlang) ---

-- VSCode ligeramente transparente
hl.window_rule({ match = { class = "^(code)$" },        opacity = "0.98 0.98" })
-- Waypaper siempre flotante
hl.window_rule({ match = { class = "^(waypaper)$" },    float   = true })
hl.window_rule({ match = { class = "^(notion-app)$" },  opacity = "0.95 0.90" })
hl.window_rule({ match = { class = "^(firefox)$" },     opacity = "0.98 0.95" })

-- --- REGLAS DE CAPAS (Layer Rules) ---
-- Look & feel para popups que no son ventanas (mako, rofi, hub eww).
-- Sin estas reglas, el blur global de decoration no aplica a las layers,
-- solo a windows.

-- mako (notifications)
hl.layer_rule({ match = { namespace = "^(notifications)$" }, blur = true, ignore_alpha = 0.0 })

-- rofi (launcher)
hl.layer_rule({ match = { namespace = "^(rofi)$" }, blur = true, ignore_alpha = 0.0, dim_around = true })

-- hub eww — sin blur: el bg 0.95 ya tapa lo de atrás, y el blur en surface
-- rectangular creaba un halo gris visible en las esquinas redondeadas.
-- El defwindow hub usa :namespace "hub" en eww.yuck — esto lo matchea.
hl.layer_rule({ match = { namespace = "^(hub)$" }, ignore_alpha = 0.0 })

-- slurp (overlay de selección) — sin animaciones. Hyprland >=0.55 aplica
-- fade-out al cerrar slurp; grim dispara antes de que termine y captura
-- restos del dim/borde. Sin anim, slurp desaparece instantáneo.
hl.layer_rule({ match = { namespace = "^(selection)$" }, no_anim = true })
