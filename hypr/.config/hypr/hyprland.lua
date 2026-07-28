-- Validar cambios SIN tocar la sesión activa (no corre nada, y detecta errores de
-- sintaxis, nombres de opción inexistentes y dispatchers que no existen):
--   Hyprland --config ~/.config/hypr/hyprland.lua --verify-config
--
-- Chequeo estático con el language server. El --configpath es OBLIGATORIO:
-- `--check` NO autodetecta el .luarc.json de al lado, y sin él tira ~200 falsos
-- "Undefined global hl".
--   cd ~/.config/hypr && lua-language-server --check "$PWD/configs" \
--       --configpath="$PWD/.luarc.json" --checklevel=Warning

require("configs.environments")
require("configs.monitors")
require("configs.settings")
require("configs.autostart")
require("configs.rules")
require("configs.workspaces")
require("configs.binds")
