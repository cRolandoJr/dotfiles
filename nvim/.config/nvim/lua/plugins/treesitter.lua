return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",   -- API estable (la nueva rama "main" rompió todo)
        build  = ":TSUpdate",
        event  = { "BufReadPost", "BufNewFile" },
        dependencies = {
            { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
            "windwp/nvim-ts-autotag",
        },
        main = "nvim-treesitter.configs",
        opts = {
            ensure_installed = {
                "bash", "c", "css", "dart", "diff", "dockerfile",
                "go", "gomod", "gosum", "gowork",
                "html", "javascript", "json", "json5",
                "lua", "luadoc", "luap",
                "markdown", "markdown_inline",
                "python", "query", "regex", "rust",
                "toml", "tsx", "typescript",
                "vim", "vimdoc", "yaml",
            },
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = { enable = true },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["ac"] = "@class.outer",
                        ["ic"] = "@class.inner",
                        ["aa"] = "@parameter.outer",
                        ["ia"] = "@parameter.inner",
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
                    goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
                },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
            require("nvim-ts-autotag").setup()
        end,
    },
}
