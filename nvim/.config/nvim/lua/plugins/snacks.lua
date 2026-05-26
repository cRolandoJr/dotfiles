-- folke/snacks.nvim: dashboard, notifier, indent, bigfile, scroll, statuscolumn,
-- words, quickfile, input, lazygit, bufdelete — todo en uno.
return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            bigfile     = { enabled = true },
            quickfile   = { enabled = true },
            statuscolumn = { enabled = true },
            indent      = { enabled = true },
            input       = { enabled = true },
            notifier    = { enabled = true, timeout = 3000 },
            scroll      = { enabled = true },
            words       = { enabled = true },
            dashboard   = {
                enabled = true,
                preset = {
                    keys = {
                        { icon = " ", key = "f", desc = "Buscar archivo",  action = ":lua Snacks.dashboard.pick('files')" },
                        { icon = " ", key = "n", desc = "Nuevo archivo",   action = ":ene | startinsert" },
                        { icon = " ", key = "g", desc = "Grep texto",      action = ":lua Snacks.dashboard.pick('live_grep')" },
                        { icon = " ", key = "r", desc = "Recientes",       action = ":lua Snacks.dashboard.pick('oldfiles')" },
                        { icon = " ", key = "c", desc = "Config",          action = ":e $MYVIMRC" },
                        { icon = " ", key = "l", desc = "Lazy",            action = ":Lazy" },
                        { icon = " ", key = "m", desc = "Mason",           action = ":Mason" },
                        { icon = " ", key = "q", desc = "Salir",           action = ":qa" },
                    },
                },
            },
        },
        keys = {
            { "<leader>gg", function() Snacks.lazygit() end,                  desc = "Lazygit" },
            { "<leader>nh", function() Snacks.notifier.show_history() end,   desc = "Historial de notificaciones" },
            { "<leader>bD", function() Snacks.bufdelete() end,                desc = "Cerrar buffer (smart)" },
        },
    },
}
