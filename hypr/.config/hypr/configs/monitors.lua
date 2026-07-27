hl.monitor({ output = "eDP-1",    mode = "1920x1080@144", position = "0x0",    scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60",  position = "1920x0", scale = 1 })

-- Catch-all: cualquier display no listado arriba (proyector, HDMI ajeno) usa su
-- modo preferido y se autoposiciona. Evita el default interno de Hyprland.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
