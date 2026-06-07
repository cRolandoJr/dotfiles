-- hardtime.nvim — fuerza buenos hábitos Vim.
--
-- Qué hace: bloquea uso repetitivo de hjkl/flechas (>3 veces seguidas) y
-- te avisa con un hint sobre el movimiento más eficiente: 6j, /pattern, f<char>, etc.
--
-- Modo BLOCK (no hint): bloquea de verdad. La fricción es intencional: cuando
-- te encuentras frustrado, ese es exactamente el momento donde aprendés un
-- nuevo movimiento idiomático.
--
-- Toggle en runtime con `:Hardtime` si necesitás desactivarlo puntualmente
-- (e.g. demos, casos legítimos donde 4 hjkl está bien).

return {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = "VeryLazy",  -- carga lazy: no afecta startup
    opts = {
        max_count = 3,              -- después de 3 hjkl/flechas seguidas, bloquea
        restriction_mode = "block", -- BLOCK = real enforcement (vs "hint" = solo aviso)
        disable_mouse = true,       -- también deshabilita mouse dentro de nvim
        hint = true,                -- muestra el hint del movimiento recomendado
        notification = true,        -- feedback visible cuando bloquea

        -- Patrones que se enseñan via hints (al detectarlos sugiere alternativa).
        -- Por defecto cubre: hjkl repetido, gg/G nav, w/e/b vs flechas, etc.

        -- Filetypes donde NO aplicar — UIs/pickers que necesitan navegación libre.
        disabled_filetypes = {
            "qf",
            "netrw",
            "NvimTree",
            "lazy",
            "mason",
            "oil",
            "TelescopePrompt",
            "TelescopeResults",
            "snacks_dashboard",
            "snacks_picker_list",
            "snacks_picker_input",
            "trouble",
            "lspinfo",
            "checkhealth",
            "help",
        },

        -- Modos donde aplicar (n = normal, v/x = visual). Insert se respeta auto.
        restricted_modes = { "n", "x" },
    },
}
