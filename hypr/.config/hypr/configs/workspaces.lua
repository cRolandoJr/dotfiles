-- ╔════════════════════════════════════════════════╗
-- ║        WORKSPACE → MONITOR (workspaces.lua)     ║
-- ╚════════════════════════════════════════════════╝
-- Sin reglas, Hyprland asigna el workspace al monitor enfocado la primera vez
-- que se invoca (impredecible). Estas reglas le dan casa fija a cada uno.
-- default = true: el workspace que el monitor muestra al conectarse / al iniciar.
--
-- Se dejan explícitas en vez de un loop: son data, no lógica, y así el diff
-- contra workspaces.conf se lee línea por línea.

-- Laptop (eDP-1, pantalla principal, a la izquierda) = primarios 1-5
hl.workspace_rule({ workspace = 1, monitor = "eDP-1", default = true })
hl.workspace_rule({ workspace = 2, monitor = "eDP-1" })
hl.workspace_rule({ workspace = 3, monitor = "eDP-1" })
hl.workspace_rule({ workspace = 4, monitor = "eDP-1" })
hl.workspace_rule({ workspace = 5, monitor = "eDP-1" })

-- Externo (HDMI-A-1, auxiliar, a la derecha) = 6-10
hl.workspace_rule({ workspace = 6,  monitor = "HDMI-A-1", default = true })
hl.workspace_rule({ workspace = 7,  monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = 8,  monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = 9,  monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = 10, monitor = "HDMI-A-1" })
