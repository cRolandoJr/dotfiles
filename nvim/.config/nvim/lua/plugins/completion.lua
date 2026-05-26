-- blink.cmp: motor de autocompletado moderno (escrito en Rust, drop-in para nvim-cmp)
return {
    {
        "saghen/blink.cmp",
        event = "InsertEnter",
        version = "*",  -- usa binarios precompilados
        dependencies = {
            {
                "L3MON4D3/LuaSnip",
                version = "v2.*",
                build = "make install_jsregexp",  -- opcional; si falla no rompe nada
                dependencies = {
                    {
                        "rafamadriz/friendly-snippets",
                        config = function()
                            require("luasnip.loaders.from_vscode").lazy_load()
                        end,
                    },
                },
            },
        },
        opts = {
            keymap = {
                preset = "default",
                ["<CR>"]    = { "accept", "fallback" },
                ["<Tab>"]   = { "select_next", "snippet_forward", "fallback" },
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
            },
            snippets = { preset = "luasnip" },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            appearance = {
                nerd_font_variant = "mono",
            },
            completion = {
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
                ghost_text    = { enabled = true },
            },
            signature = { enabled = true },
        },
        opts_extend = { "sources.default" },
    },
}
