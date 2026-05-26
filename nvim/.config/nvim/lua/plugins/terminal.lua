return {
    {
        "akinsho/toggleterm.nvim",
        cmd = { "ToggleTerm", "TermExec" },
        keys = {
            { "<F4>",       "<cmd>ToggleTerm<cr>",                          desc = "Terminal flotante" },
            { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",          desc = "Term flotante" },
            { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>",     desc = "Term horizontal" },
            { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Term vertical" },
        },
        opts = {
            open_mapping = [[<F4>]],
            direction    = "float",
            float_opts   = { border = "rounded" },
            shade_terminals = true,
            persist_mode    = true,
        },
    },
}
