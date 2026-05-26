return {
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufNewFile", "BufWritePost" },
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                python          = { "ruff" },
                javascript      = { "eslint_d" },
                javascriptreact = { "eslint_d" },
                typescript      = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                go              = { "golangcilint" },
                sh              = { "shellcheck" },
                bash            = { "shellcheck" },
                markdown        = { "markdownlint" },
                yaml            = { "yamllint" },
                dockerfile      = { "hadolint" },
            }

            local grp = vim.api.nvim_create_augroup("rolando_lint", { clear = true })
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                group = grp,
                callback = function() lint.try_lint() end,
            })
        end,
    },
}
