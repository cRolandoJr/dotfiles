-- Config de Hyprland en Lua — MIGRACIÓN EN CURSO.
--
-- Se llama hyprland-wip.lua a propósito: Hyprland elige el provider de config al
-- ARRANCAR la sesión y toma `hyprland.lua` por convención, así que un archivo
-- parcial con ese nombre rompería la sesión ante cualquier relogin o crash.
-- Mientras se llame -wip, Hyprland lo ignora y el .conf sigue siendo el activo.
--
-- Verificar sin tocar la sesión:
--   Hyprland --config ~/.config/hypr/hyprland-wip.lua --verify-config
--
-- Al terminar la migración: renombrar a hyprland.lua y volver a entrar a la sesión.
-- Rollback: renombrar de vuelta a hyprland-wip.lua y relogin.

require("configs.settings")
