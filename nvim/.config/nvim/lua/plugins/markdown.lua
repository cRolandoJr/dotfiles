return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            heading  = { sign = false },
            code     = { sign = false, width = "block", border = "thin" },
            checkbox = {
                unchecked = { icon = "󰄱 " },
                checked   = { icon = " " },
            },
        },
    },
}
