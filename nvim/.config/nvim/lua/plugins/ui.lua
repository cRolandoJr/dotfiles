return {
    -- Iconos
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = {
            options = {
                theme = "tokyonight",
                globalstatus = true,
                section_separators = { left = "", right = "" },
                component_separators = { left = "│", right = "│" },
            },
            sections = {
                lualine_b = { "branch", "diff" },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "diagnostics", "encoding", "filetype" },
            },
        },
    },

    -- Bufferline (pestañas)
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        keys = {
            { "<leader>bp", "<cmd>BufferLineTogglePin<cr>",     desc = "Pin buffer" },
            { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>",   desc = "Cerrar otros buffers" },
            { "[B",         "<cmd>BufferLineMovePrev<cr>",      desc = "Mover buffer ←" },
            { "]B",         "<cmd>BufferLineMoveNext<cr>",      desc = "Mover buffer →" },
        },
        opts = {
            options = {
                diagnostics = "nvim_lsp",
                always_show_bufferline = false,
                offsets = {
                    { filetype = "NvimTree", text = "Files", text_align = "left", separator = true },
                },
            },
        },
    },
}
