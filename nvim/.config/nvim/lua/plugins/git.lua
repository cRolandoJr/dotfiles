return {
    -- Git en el signcolumn + blame + acciones por hunk
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add          = { text = "▎" },
                change       = { text = "▎" },
                delete       = { text = "" },
                topdelete    = { text = "" },
                changedelete = { text = "▎" },
                untracked    = { text = "▎" },
            },
            current_line_blame = false,
            on_attach = function(buffer)
                local gs = package.loaded.gitsigns
                local function map(mode, l, r, desc)
                    vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
                end
                map("n", "]h", function() gs.nav_hunk("next") end, "Hunk siguiente")
                map("n", "[h", function() gs.nav_hunk("prev") end, "Hunk anterior")
                map("n", "<leader>hs", gs.stage_hunk,    "Stage hunk")
                map("n", "<leader>hr", gs.reset_hunk,    "Reset hunk")
                map("n", "<leader>hS", gs.stage_buffer,  "Stage buffer")
                map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
                map("n", "<leader>hR", gs.reset_buffer,  "Reset buffer")
                map("n", "<leader>hp", gs.preview_hunk,  "Preview hunk")
                map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame línea")
                map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle blame inline")
                map("n", "<leader>hd", gs.diffthis,      "Diff archivo")
            end,
        },
    },

    -- Comandos Git clásicos (:Git status, :Git blame, etc.)
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse" },
    },
}
