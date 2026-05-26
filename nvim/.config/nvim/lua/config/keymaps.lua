local map = vim.keymap.set

-- Guardar / salir
map({ "n", "i", "v" }, "<C-s>", "<esc><cmd>w<cr>", { desc = "Guardar" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Salir de Neovim" })

-- Limpiar highlight de búsqueda
map("n", "<esc>", "<cmd>noh<cr><esc>", { desc = "Limpiar highlight" })

-- Movimiento entre splits
map("n", "<C-h>", "<C-w>h", { desc = "Split izquierda" })
map("n", "<C-j>", "<C-w>j", { desc = "Split abajo" })
map("n", "<C-k>", "<C-w>k", { desc = "Split arriba" })
map("n", "<C-l>", "<C-w>l", { desc = "Split derecha" })

-- Resize con Ctrl+flechas
map("n", "<C-Up>",    "<cmd>resize +2<cr>")
map("n", "<C-Down>",  "<cmd>resize -2<cr>")
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>")
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>")

-- Mover líneas con Alt+jk
map("n", "<A-j>", "<cmd>m .+1<cr>==",       { desc = "Mover línea abajo" })
map("n", "<A-k>", "<cmd>m .-2<cr>==",       { desc = "Mover línea arriba" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv",       { desc = "Mover selección abajo" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv",       { desc = "Mover selección arriba" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi")
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi")

-- Indentación visual sin perder selección
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Pegar sin pisar el registro
map("v", "p", '"_dP', { desc = "Pegar sin pisar registro" })

-- Buffers
map("n", "<S-l>", "<cmd>bnext<cr>",       { desc = "Buffer siguiente" })
map("n", "<S-h>", "<cmd>bprevious<cr>",   { desc = "Buffer anterior" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Cerrar buffer" })

-- Diagnostics (API moderna; cae a goto_* si Neovim es viejo)
local jump_next = vim.diagnostic.jump and function() vim.diagnostic.jump({ count = 1, float = true }) end
    or vim.diagnostic.goto_next
local jump_prev = vim.diagnostic.jump and function() vim.diagnostic.jump({ count = -1, float = true }) end
    or vim.diagnostic.goto_prev
map("n", "]d", jump_next, { desc = "Diagnóstico siguiente" })
map("n", "[d", jump_prev, { desc = "Diagnóstico anterior" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Diagnóstico flotante" })
