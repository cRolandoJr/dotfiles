-- ╔════════════════════════════════════════════════╗
-- ║       SETTINGS, LOOK & FEEL (settings.lua)     ║
-- ╚════════════════════════════════════════════════╝

hl.config({
    -- INPUT (Teclado y Ratón)
    input = {
        kb_layout    = "us, latam",
        kb_variant   = ",",
        kb_options   = "grp:alt_shift_toggle",
        follow_mouse = 1,
        sensitivity  = 0.7, -- -1.0 <-> 1.0, 0 = sin modificación

        touchpad = {
            natural_scroll = true,
        },
    },

    -- GENERAL (Bordes Dinámicos y Layout)
    general = {
        gaps_in     = 5,
        gaps_out    = 7,
        border_size = 1,

        col = {
            -- Deep Ocean borders
            active_border   = { colors = { "rgb(00b4d8)", "rgb(3b82f6)" }, angle = 45 }, -- cyan → azul NixOS
            inactive_border = "rgb(1a2744)",                                             -- navy border
        },

        resize_on_border = true,
        layout           = "dwindle",
        allow_tearing    = false,
    },

    cursor = {
        no_hardware_cursors = true,
    },

    -- DECORATION (Sombras, Redondeo y Blur)
    decoration = {
        rounding = 5,

        shadow = {
            enabled      = true,
            range        = 50,
            render_power = 9,
            color        = "rgba(0,0,0,0.7)",
        },

        blur = {
            enabled  = true,
            size     = 4,
            passes   = 2,    -- dos pasadas gaussianas, blur más suave
            noise    = 0.01, -- grano sutil que rompe la uniformidad del glass
            contrast = 0.9,
        },
    },

    animations = {
        enabled = true,
    },

    -- LAYOUTS
    dwindle = {
        preserve_split = true,
        force_split    = 2, -- ventana nueva siempre cae a la der/abajo (determinista; 0 = sigue al mouse)
    },

    -- MISCELLANEOUS
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
        session_lock_xray       = true,  -- en el .conf era 1; el efectivo ya era bool true

        -- Swallow: cuando lanzás `mpv foto.jpg` desde foot, foot desaparece
        -- mientras mpv corre y reaparece al cerrarlo. Layout limpio.
        -- exception_regex: TUIs que abren ventanas hijo no deben triggerar swallow.
        enable_swallow          = true,
        swallow_regex           = "^(foot|foot_float)$",
        swallow_exception_regex = "^(nvim|vim|btop|lazygit|yazi)$",
    },

    -- XWAYLAND
    xwayland = {
        enabled            = true,
        force_zero_scaling = true,
    },
})

-- GESTURES
-- 3 dedos horizontal → cambia de workspace (izq = anterior, der = siguiente).
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- ANIMATIONS (curvas personalizadas)
-- Los 4 números del `bezier =` de hyprlang son dos puntos de control: {x1,y1}, {x2,y2}.
hl.curve("myBezier",       { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("smoothOut",      { type = "bezier", points = { { 0.16, 1 },   { 0.3, 1 } } })   -- OutExpo: snappy sin overshoot, para popups
hl.curve("workspaceCurve", { type = "bezier", points = { { 0.25, 1 },   { 0.5, 1 } } })   -- OutQuart: arranca rápido, frena suave

hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 5,  bezier = "workspaceCurve", style = "slide" })
hl.animation({ leaf = "layers",      enabled = true, speed = 5,  bezier = "smoothOut", style = "slide" })

-- PERIPHERALS (Dispositivos específicos)
hl.device({ name = "epic mouse V1", sensitivity = -0.5 })
