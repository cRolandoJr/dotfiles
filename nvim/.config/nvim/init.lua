-- ╔════════════════════════════════════════════════════════════════╗
-- ║   N  E  O  V  I  M  ·  lazy.nvim · modular                     ║
-- ║   cRolandoJr · github.com/cRolandoJr                           ║
-- ╚════════════════════════════════════════════════════════════════╝

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
