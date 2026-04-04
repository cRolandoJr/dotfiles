" ========= Configuración Visual & Pro (Rolando) =========
set number              " Números fijos (como pediste)
set norelativenumber    " Sin números relativos para menos ruido visual
set laststatus=3        " Barra de estado única al fondo (minimalismo puro)
set cursorline          " Resalta la línea donde estás
set termguicolors       " Colores de alta fidelidad
set scrolloff=8         " Mantiene contexto al bajar/subir
set expandtab           " Espacios en vez de tabs
set shiftwidth=4
set tabstop=4
set clipboard=unnamedplus " Portapapeles del sistema
set signcolumn=yes      " Columna lateral fija para iconos de error
set noswapfile          " Sin archivos temporales .swp

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

" Programación (Go/Python/Bash)
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'
Plug 'onsails/lspkind-nvim'

" Herramientas
Plug 'akinsho/toggleterm.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'tpope/vim-fugitive'

call plug#end()

" Aplicar tema
colorscheme tokyonight

" ========= Lógica en Lua (Bloque Único y Seguro) =========
lua << EOF
-- Función para que Neovim no explote si falta un plugin
local function safe_load(module, config)
    local ok, m = pcall(require, module)
    if ok then config(m) end
end

-- 1. Barra de estado Global (Look Minimalista)
safe_load('lualine', function(l)
    l.setup({
        options = {
            theme = 'tokyonight',
            globalstatus = true,
            component_separators = '',
            section_separators = { left = '', right = '' },
        }
    })
end)

-- 2. Guías de indentación limpias
safe_load('ibl', function(ibl) 
    ibl.setup({ scope = { enabled = false } }) 
end)

-- 3. Ayuda de atajos (Which-key)
safe_load('which-key', function(wk) wk.setup() end)

-- Inicializar el explorador de archivos
safe_load('nvim-tree', function(tree) tree.setup() end)

-- 4. Resaltado inteligente (Treesitter)
safe_load('nvim-treesitter.configs', function(ts)
    ts.setup({
        ensure_installed = { 'go', 'python', 'lua', 'bash', 'markdown' },
        highlight = { enable = true },
    })
end)

-- 5. Terminal y Autopairs
safe_load('toggleterm', function(t) t.setup() end)
safe_load('nvim-autopairs', function(a) a.setup({}) end)
EOF

" ========= Atajos de Teclado (Leader es Espacio) =========
let mapleader = " "

" Explorador de archivos (F2)
nnoremap <F2> :NvimTreeToggle<CR>

" Terminal integrada (F4)
nnoremap <F4> :ToggleTerm<CR>

" Buscador Telescope (Pro)
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>

" Guardar rápido
nnoremap <C-s> :w<CR>
