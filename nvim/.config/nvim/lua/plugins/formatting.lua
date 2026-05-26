return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd   = { "ConformInfo" },
        keys = {
            {
                "<leader>cf",
                function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
                mode = { "n", "v" },
                desc = "Formatear archivo/selección",
            },
        },
        opts = {
            formatters_by_ft = {
                lua             = { "stylua" },
                python          = { "ruff_format", "ruff_organize_imports" },
                go              = { "goimports", "gofmt" },
                rust            = { "rustfmt" },
                javascript      = { "prettierd", "prettier", stop_after_first = true },
                javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                typescript      = { "prettierd", "prettier", stop_after_first = true },
                typescriptreact = { "prettierd", "prettier", stop_after_first = true },
                vue             = { "prettierd", "prettier", stop_after_first = true },
                html            = { "prettierd", "prettier", stop_after_first = true },
                css             = { "prettierd", "prettier", stop_after_first = true },
                scss            = { "prettierd", "prettier", stop_after_first = true },
                json            = { "prettierd", "prettier", stop_after_first = true },
                jsonc           = { "prettierd", "prettier", stop_after_first = true },
                yaml            = { "prettierd", "prettier", stop_after_first = true },
                markdown        = { "prettierd", "prettier", stop_after_first = true },
                sh              = { "shfmt" },
                bash            = { "shfmt" },
                dart            = { "dart_format" },
            },
            format_on_save = function(bufnr)
                if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
                    return
                end
                return { timeout_ms = 1500, lsp_format = "fallback" }
            end,
        },
        init = function()
            vim.api.nvim_create_user_command("FormatDisable", function(args)
                if args.bang then
                    vim.b.disable_autoformat = true
                else
                    vim.g.disable_autoformat = true
                end
            end, { desc = "Desactivar autoformat (bang = solo buffer)", bang = true })

            vim.api.nvim_create_user_command("FormatEnable", function()
                vim.b.disable_autoformat = false
                vim.g.disable_autoformat = false
            end, { desc = "Reactivar autoformat" })
        end,
    },
}
