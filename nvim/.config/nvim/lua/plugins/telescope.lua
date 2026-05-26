return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>",          desc = "Buscar archivos" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>",           desc = "Grep en el proyecto" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>",             desc = "Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>",           desc = "Help tags" },
            { "<leader>fr", "<cmd>Telescope oldfiles<cr>",            desc = "Recientes" },
            { "<leader>fk", "<cmd>Telescope keymaps<cr>",             desc = "Keymaps" },
            { "<leader>fd", "<cmd>Telescope diagnostics<cr>",         desc = "Diagnósticos" },
            { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Símbolos del archivo" },
            { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Símbolos del workspace" },
            { "<leader>fw", "<cmd>Telescope grep_string<cr>",         desc = "Grep palabra bajo cursor" },
            { "<leader>/",  "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buscar en buffer" },
        },
        opts = {
            defaults = {
                path_display = { "truncate" },
                sorting_strategy = "ascending",
                layout_config = { prompt_position = "top" },
                mappings = {
                    i = {
                        ["<C-j>"] = "move_selection_next",
                        ["<C-k>"] = "move_selection_previous",
                    },
                },
            },
        },
        config = function(_, opts)
            local telescope = require("telescope")
            telescope.setup(opts)
            pcall(telescope.load_extension, "fzf")
        end,
    },
}
