-- Vars de apps (Qt/Electron/Mozilla) viven en home.sessionVariables (Nix);
-- UWSM las propaga a la sesión. Aquí solo lo específico de Hyprland.
-- Nota: en Lua el valor va siempre como string, incluso si es numérico.
hl.env("XCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
