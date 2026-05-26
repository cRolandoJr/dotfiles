-- ╔════════════════════════════════════════════════════════════════╗
-- ║              Neovim config (lazy.nvim + modular)               ║
-- ╚════════════════════════════════════════════════════════════════╝

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
