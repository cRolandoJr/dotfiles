-- nvim-treesitter rama "main" (API nueva, compatible con Neovim >= 0.12).
-- La rama "master" quedó congelada y no soporta la API de directives de 0.11+.
--
-- Diferencias importantes vs. master:
--   - No hay `setup({ highlight = {...}, indent = {...} })`.
--     Esas features las activamos por FileType en lua/config/autocmds.lua.
--   - Los parsers se instalan con `require('nvim-treesitter').install({...})`.
--   - No soporta lazy-loading (lazy = false obligado).
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
            })

            -- install() es asíncrono e idempotente: si el parser ya está
            -- instalado y al día, no hace nada.
            require("nvim-treesitter").install({
                "bash", "c", "css", "dart", "diff", "dockerfile",
                "go", "gomod", "gosum", "gowork",
                "html", "javascript", "json", "json5",
                "lua", "luadoc", "luap",
                "markdown", "markdown_inline",
                "python", "query", "regex", "rust",
                "toml", "tsx", "typescript",
                "vim", "vimdoc", "yaml",
            })
        end,
    },

    -- autotag funciona standalone con la API de Neovim; ya no necesita
    -- a nvim-treesitter como dependency.
    {
        "windwp/nvim-ts-autotag",
        event = { "BufReadPost", "BufNewFile" },
        config = true,
    },

    -- textobjects rama "main": misma API nueva que treesitter. setup() solo
    -- configura comportamiento; los keymaps los registramos manualmente
    -- llamando a las funciones del módulo.
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        lazy = false,
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = { lookahead = true },
                move = { set_jumps = true },
            })

            local select = function(query)
                return function()
                    require("nvim-treesitter-textobjects.select")
                        .select_textobject(query, "textobjects")
                end
            end
            local goto_next = function(query)
                return function()
                    require("nvim-treesitter-textobjects.move")
                        .goto_next_start(query, "textobjects")
                end
            end
            local goto_prev = function(query)
                return function()
                    require("nvim-treesitter-textobjects.move")
                        .goto_previous_start(query, "textobjects")
                end
            end

            -- Selección (visual + operator-pending)
            vim.keymap.set({ "x", "o" }, "af", select("@function.outer"),  { desc = "función exterior" })
            vim.keymap.set({ "x", "o" }, "if", select("@function.inner"),  { desc = "función interior" })
            vim.keymap.set({ "x", "o" }, "ac", select("@class.outer"),     { desc = "clase exterior" })
            vim.keymap.set({ "x", "o" }, "ic", select("@class.inner"),     { desc = "clase interior" })
            vim.keymap.set({ "x", "o" }, "aa", select("@parameter.outer"), { desc = "parámetro exterior" })
            vim.keymap.set({ "x", "o" }, "ia", select("@parameter.inner"), { desc = "parámetro interior" })

            -- Movimientos
            vim.keymap.set({ "n", "x", "o" }, "]f", goto_next("@function.outer"), { desc = "→ función" })
            vim.keymap.set({ "n", "x", "o" }, "]c", goto_next("@class.outer"),    { desc = "→ clase" })
            vim.keymap.set({ "n", "x", "o" }, "[f", goto_prev("@function.outer"), { desc = "← función" })
            vim.keymap.set({ "n", "x", "o" }, "[c", goto_prev("@class.outer"),    { desc = "← clase" })
        end,
    },
}
