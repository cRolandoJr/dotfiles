-- LSP sin Mason: los binarios vienen del sistema (nix / pacman).
-- Si un binario no está en PATH, ese server simplemente no se activa.
-- Usa la API nativa de nvim 0.11+: vim.lsp.config + vim.lsp.enable.
return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "saghen/blink.cmp" },
        config = function()
            -- name → { bin = "<exe-en-PATH>", settings = ... }
            local servers = {
                gopls = {
                    bin = "gopls",
                    settings = {
                        gopls = {
                            usePlaceholders = true,
                            staticcheck     = true,
                            gofumpt         = true,
                            analyses        = { unusedparams = true },
                        },
                    },
                },
                pyright = {
                    bin = "pyright-langserver",
                    settings = {
                        python = {
                            analysis = {
                                typeCheckingMode       = "basic",
                                autoSearchPaths        = true,
                                useLibraryCodeForTypes = true,
                            },
                        },
                    },
                },
                ts_ls   = { bin = "typescript-language-server" },
                html    = { bin = "vscode-html-language-server" },
                cssls   = { bin = "vscode-css-language-server" },
                jsonls  = { bin = "vscode-json-language-server" },
                yamlls  = { bin = "yaml-language-server" },
                bashls  = { bin = "bash-language-server" },
                lua_ls  = {
                    bin = "lua-language-server",
                    settings = {
                        Lua = {
                            workspace   = { checkThirdParty = false },
                            telemetry   = { enable = false },
                            diagnostics = { globals = { "vim", "Snacks" } },
                            completion  = { callSnippet = "Replace" },
                            hint        = { enable = true },
                        },
                    },
                },
            }

            -- capabilities globales (blink.cmp) vía config('*')
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local ok_blink, blink = pcall(require, "blink.cmp")
            if ok_blink then
                capabilities = blink.get_lsp_capabilities(capabilities)
            end
            vim.lsp.config("*", { capabilities = capabilities })

            -- keymaps vía LspAttach (reemplaza on_attach por-server)
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local bufnr = args.buf
                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
                    end
                    map("n", "gd",         vim.lsp.buf.definition,      "LSP: definición")
                    map("n", "gD",         vim.lsp.buf.declaration,     "LSP: declaración")
                    map("n", "gr",         vim.lsp.buf.references,      "LSP: referencias")
                    map("n", "gi",         vim.lsp.buf.implementation,  "LSP: implementación")
                    map("n", "gt",         vim.lsp.buf.type_definition, "LSP: type definition")
                    map("n", "K",          vim.lsp.buf.hover,           "LSP: hover")
                    map({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, "LSP: signature")
                    map("n", "<leader>rn", vim.lsp.buf.rename,          "LSP: renombrar")
                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "LSP: code action")

                    if vim.lsp.inlay_hint then
                        map("n", "<leader>ih", function()
                            vim.lsp.inlay_hint.enable(
                                not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
                                { bufnr = bufnr }
                            )
                        end, "LSP: toggle inlay hints")
                    end
                end,
            })

            -- Configurar y habilitar sólo los servers cuyo binario está en PATH.
            -- nvim-lspconfig sigue siendo útil: provee defaults (cmd, root, filetypes)
            -- en lsp/<name>.lua del runtimepath, que vim.lsp.enable() consume.
            local missing = {}
            for name, spec in pairs(servers) do
                if vim.fn.executable(spec.bin) == 1 then
                    if spec.settings then
                        vim.lsp.config(name, { settings = spec.settings })
                    end
                    vim.lsp.enable(name)
                else
                    table.insert(missing, name .. " (" .. spec.bin .. ")")
                end
            end

            if #missing > 0 then
                vim.schedule(function()
                    vim.notify(
                        "LSPs no disponibles (instalá los binarios):\n  " .. table.concat(missing, "\n  "),
                        vim.log.levels.INFO,
                        { title = "LSP" }
                    )
                end)
            end

            -- rust_analyzer lo configura rustaceanvim (lang-rust.lua).
            -- Sin on_attach: los keymaps los pone el autocmd LspAttach de arriba.
            vim.g.rustaceanvim = {
                server = {
                    capabilities = capabilities,
                    default_settings = {
                        ["rust-analyzer"] = {
                            cargo = { allFeatures = true },
                            check = { command = "clippy" },
                        },
                    },
                },
            }
        end,
    },
}
