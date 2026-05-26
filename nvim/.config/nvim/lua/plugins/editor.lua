return {
    -- which-key: ayuda contextual de keymaps
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            delay = 300,
        },
    },

    -- flash.nvim: saltos rápidos (reemplazo moderno de easymotion/leap)
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "s", function() require("flash").jump() end,       mode = { "n", "x", "o" }, desc = "Flash" },
            { "S", function() require("flash").treesitter() end, mode = { "n", "x", "o" }, desc = "Flash treesitter" },
            { "r", function() require("flash").remote() end,     mode = "o",               desc = "Remote flash" },
        },
    },

    -- Surround: ysiw"  cs'"  ds"
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        opts = {},
    },

    -- Pares automáticos
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = { check_ts = true },
    },

    -- TODO / FIXME / HACK highlights
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
        keys = {
            { "]t",         function() require("todo-comments").jump_next() end, desc = "TODO siguiente" },
            { "[t",         function() require("todo-comments").jump_prev() end, desc = "TODO anterior" },
            { "<leader>ft", "<cmd>TodoTelescope<cr>",                              desc = "Buscar TODOs" },
        },
    },

    -- Árbol de archivos clásico
    {
        "nvim-tree/nvim-tree.lua",
        cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
        keys = {
            { "<F2>",       "<cmd>NvimTreeToggle<cr>",   desc = "Árbol de archivos" },
            { "<leader>e",  "<cmd>NvimTreeFindFile<cr>", desc = "Localizar archivo actual" },
        },
        opts = {
            view = { width = 32, side = "left" },
            renderer = { group_empty = true, indent_markers = { enable = true } },
            filters = { dotfiles = false },
            git = { enable = true, ignore = false },
        },
    },

    -- oil.nvim: editás el filesystem como un buffer
    {
        "stevearc/oil.nvim",
        cmd = "Oil",
        keys = {
            { "-", "<cmd>Oil<cr>", desc = "Oil (filesystem buffer)" },
        },
        opts = {
            view_options = { show_hidden = true },
            keymaps = {
                ["q"] = "actions.close",
            },
        },
    },
}
