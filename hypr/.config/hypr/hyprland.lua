-- Config de Hyprland en Lua. Activa desde el 27-jul-2026.
--
-- Los .conf de al lado quedan como fallback: el provider de config se elige al
-- ARRANCAR la sesión y por extensión del archivo, así que para volver a hyprlang
-- basta renombrar este archivo (a hyprland-wip.lua, por ejemplo) y relogin.
--
-- Validar cambios SIN tocar la sesión activa (no corre nada, y detecta errores de
-- sintaxis, nombres de opción inexistentes y dispatchers que no existen):
--   Hyprland --config ~/.config/hypr/hyprland.lua --verify-config
--
-- Provider en uso:  hyprctl systeminfo | grep configProvider
--
-- Chequeo estático con el language server (tipos, nombres de campo, globals).
-- El --configpath es OBLIGATORIO: `--check` NO autodetecta el .luarc.json de al
-- lado, y sin él tira ~200 falsos "Undefined global hl".
--   cd ~/.config/hypr && lua-language-server --check "$PWD/configs" \
--       --configpath="$PWD/.luarc.json" --checklevel=Warning

require("configs.environments")
require("configs.monitors")
require("configs.settings")
require("configs.autostart")
require("configs.rules")
require("configs.workspaces")
require("configs.binds")
