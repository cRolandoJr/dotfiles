local opt = vim.opt

-- UI
opt.number         = true
opt.relativenumber = false
opt.cursorline     = true
opt.signcolumn     = "yes"
opt.termguicolors  = true
opt.laststatus     = 3            -- statusline global
opt.showmode       = false        -- lualine ya lo muestra
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.wrap           = false
opt.pumheight      = 10
opt.conceallevel   = 2            -- markdown
opt.list           = true
opt.listchars      = { tab = "→ ", trail = "·", nbsp = "␣" }

-- Edición
opt.expandtab    = true
opt.shiftwidth   = 4
opt.tabstop      = 4
opt.smartindent  = true
opt.ignorecase   = true
opt.smartcase    = true
opt.clipboard    = "unnamedplus"
opt.completeopt  = { "menu", "menuone", "noselect" }

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300
opt.mouse      = "a"

-- Archivos
opt.swapfile   = false
opt.undofile   = true
opt.undolevels = 10000
opt.backup     = false

-- Búsqueda
opt.inccommand = "split"

-- Diagnostics
vim.diagnostic.config({
    virtual_text = { prefix = "●", spacing = 2 },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded", source = true },
})
