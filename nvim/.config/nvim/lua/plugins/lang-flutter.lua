return {
    {
        "akinsho/flutter-tools.nvim",
        ft = { "dart" },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim",
        },
        opts = {
            lsp = {
                settings = {
                    showTodos               = true,
                    completeFunctionCalls   = true,
                    renameFilesWithClasses  = "prompt",
                    enableSnippets          = true,
                },
            },
            widget_guides = { enabled = true },
            dev_log       = { enabled = true, open_cmd = "tabedit" },
        },
    },
}
