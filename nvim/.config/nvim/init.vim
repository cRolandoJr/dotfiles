" ========= Configuración Visual & Pro (Rolando) =========
set number              " Números fijos
set norelativenumber    " Sin números relativos
set laststatus=3        " Barra de estado única al fondo
set cursorline          " Resalta la línea actual
set termguicolors       " Colores de alta fidelidad
set scrolloff=8         " Margen de scroll
set expandtab           " Espacios en vez de tabs
set shiftwidth=4
set tabstop=4
set clipboard=unnamedplus " Portapapeles del sistema
set signcolumn=yes      " Columna para iconos de error
set noswapfile          " Sin archivos temporales

" ========= Plugins (vim-plug) =========
call plug#begin('~/.local/share/nvim/plugged')

" Estética y UI
Plug 'folke/tokyonight.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-lualine/lualine.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'folke/which-key.nvim'

" Navegación y Proyectos
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'

" Programación & LSP (Cerebro)
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'            " Colección de configs para LSP
Plug 'hrsh7th/nvim-cmp'                 " Autocompletado
Plug 'hrsh7th/cmp-nvim-lsp'             " Fuente LSP para cmp
Plug 'L3MON4D3/LuaSnip'                 " Snippets
Plug 'onsails/lspkind-nvim'             " Iconos
Plug 'akinsho/flutter-tools.nvim'       " Flutter Pro

" Herramientas
Plug 'akinsho/toggleterm.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'tpope/vim-fugitive'

call plug#end()

" Aplicar tema
colorscheme tokyonight

" ========= Lógica en Lua (Estilo Neovim 0.11+) =========
lua << EOF
-- Función "Escudo" para evitar errores si falta un plugin
local function safe_load(module, config)
    local ok, m = pcall(require, module)
    if ok then config(m) end
end

-- 1. UI & Estética
safe_load('lualine', function(l)
    l.setup({ options = { theme = 'tokyonight', globalstatus = true } })
end)
safe_load('ibl', function(ibl) ibl.setup({ scope = { enabled = false } }) end)
safe_load('which-key', function(wk) wk.setup() end)
safe_load('nvim-tree', function(tree) tree.setup() end)

-- 2. Resaltado (Treesitter)
safe_load('nvim-treesitter.configs', function(ts)
    ts.setup({
        ensure_installed = { 'go', 'python', 'lua', 'bash', 'markdown', 'dart' },
        highlight = { 
            enable = true,
            additional_vim_regex_highlighting = true,
        },
        -- Esto mejora el resaltado de bloques de código
        indent = { enable = true },
    })
end)
-- 3. CONFIGURACIÓN LSP (Cerebro Moderno)

-- Definimos los "Superpoderes" (Atajos de teclado)
local on_attach = function(client, bufnr)
    local opts = { noremap=true, silent=true }
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

    buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

    if client.server_capabilities.semanticTokensProvider then
        vim.lsp.semantic_tokens.start(bufnr, client.id)
    end
end

-- Capacidades para el autocompletado
local capabilities = {}
local ok_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if ok_cmp then capabilities = cmp_lsp.default_capabilities() end

-- ACTIVACIÓN NATIVA (Para evitar errores de deprecación en Neovim 0.11+)
-- Ya no usamos require('lspconfig').setup, usamos vim.lsp.config y enable

-- Configuración para Go (gopls)
vim.lsp.config('gopls', { 
    on_attach = on_attach, 
    capabilities = capabilities 
})
vim.lsp.enable('gopls')

-- Configuración para Python (pyright)
vim.lsp.config('pyright', { 
    on_attach = on_attach, 
    capabilities = capabilities 
})
vim.lsp.enable('pyright')

-- 4. Flutter & Dart Pro
safe_load('flutter-tools', function(ft)
    ft.setup({ 
        lsp = { 
            on_attach = on_attach, 
            capabilities = capabilities,
            settings = {
                showTodos = true,
                completeFunctionCalls = true,
            }
        } 
    })
end)

-- 5. Terminal y Autopairs
safe_load('toggleterm', function(t) t.setup() end)
safe_load('nvim-autopairs', function(a) a.setup({}) end)

-- Configuración del motor de autocompletado (nvim-cmp)
safe_load('cmp', function(cmp)
    local lspkind = require('lspkind')
    cmp.setup({
        snippet = {
            expand = function(args) require('luasnip').lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Enter para confirmar
            ['<Tab>'] = cmp.mapping.select_next_item(),        -- Tab para bajar
            ['<S-Tab>'] = cmp.mapping.select_prev_item(),    -- Shift+Tab para subir
        }),
        sources = cmp.config.sources({
            { name = 'nvim_lsp' }, -- Sugerencias del cerebro (LSP)
            { name = 'luasnip' },  -- Sugerencias de tus snippets
        }, {
            { name = 'buffer' },   -- Sugerencias de palabras en el mismo archivo
        }),
        formatting = {
            format = lspkind.cmp_format({ with_text = true, menu = ({
                nvim_lsp = "[LSP]",
                luasnip  = "[Snippet]",
                buffer   = "[Buffer]",
            })}),
        },
    })
end)

EOF

" ========= Atajos de Teclado (Leader = Espacio) =========
let mapleader = " "

" Explorador de archivos (F2)
nnoremap <F2> :NvimTreeToggle<CR>

" Terminal integrada (F4)
nnoremap <F4> :ToggleTerm<CR>

" Buscador Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>

" Guardar rápido
nnoremap <C-s> :w<CR>
