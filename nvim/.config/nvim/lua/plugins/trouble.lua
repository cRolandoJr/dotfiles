return {
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                    desc = "Diagnósticos (Trouble)" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",       desc = "Diagnósticos del buffer" },
            { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",            desc = "Símbolos" },
            { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP refs/defs" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                         desc = "Quickfix" },
            { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                        desc = "Location list" },
        },
        opts = {},
    },
}
