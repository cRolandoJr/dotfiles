---@diagnostic disable: undefined-global
-- ↑ `vim` es el global del runtime de Neovim. lua-language-server lo reconoce
-- cuando lee `.luarc.json` del workspace, pero análisis externos pueden no
-- encontrar ese archivo. El pragma silencia la advertencia en cualquier contexto.

local function augroup(name)
    return vim.api.nvim_create_augroup("rolando_" .. name, { clear = true })
end

-- Resaltar yank brevemente
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        (vim.hl or vim.highlight).on_yank({ timeout = 200 })
    end,
})

-- Volver a la última posición del cursor al abrir un archivo
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local lcount = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Cerrar con `q` ciertos buffers especiales
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = { "help", "qf", "lspinfo", "checkhealth", "man", "notify", "trouble" },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})

-- Crear directorios automáticamente al guardar
vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup("auto_create_dir"),
    callback = function(event)
        if event.match:match("^%w%w+://") then return end
        local file = (vim.uv or vim.loop).fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

-- Reajustar splits cuando cambia el tamaño de la terminal
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup("resize_splits"),
    callback = function()
        local current_tab = vim.fn.tabpagenr()
        vim.cmd("tabdo wincmd =")
        vim.cmd("tabnext " .. current_tab)
    end,
})

-- nvim-treesitter rama "main": highlight, folds e indent ya no se activan
-- desde `setup()`. Acá los enchufamos por FileType. `pcall` silencia el caso
-- de filetypes sin parser instalado (e.g. un .conf raro).
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("treesitter_features"),
    callback = function(args)
        if pcall(vim.treesitter.start) then
            vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.wo[0][0].foldmethod = "expr"
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})

-- GTK CSS (waybar, gtk-3.0/gtk.css, gtk-4.0/gtk.css): silenciar diagnósticos de cssls.
--
-- Por qué: cssls valida contra W3C CSS. GTK CSS es un superset que incluye
-- `@define-color`, `-gtk-icon-source`, etc. El server no puede configurarse
-- para aceptar esas extensiones sin un descriptor customData complejo.
--
-- Solución: cuando cssls se adjunta a un buffer GTK CSS, sobreescribimos
-- su handler de diagnósticos con una función vacía → el LSP sigue activo
-- (hover, completado) pero no publica ningún error en el buffer.
-- prettierd también se desactiva aquí (ver vim.b.gtk_css) porque reescribiría
-- las líneas `@define-color` al guardar.
vim.api.nvim_create_autocmd("LspAttach", {
    group = augroup("gtk_css_lsp"),
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= "cssls" then return end

        -- Verificar que el path del buffer corresponde a GTK CSS.
        local path = vim.api.nvim_buf_get_name(bufnr)
        local is_gtk_css = path:match("/waybar/") or
                           path:match("/gtk%-3%.0/gtk%.css$") or
                           path:match("/gtk%-4%.0/gtk%.css$")
        if not is_gtk_css then return end

        -- Marcar el buffer para conform.nvim (evita que prettierd lo toque).
        vim.b[bufnr].gtk_css = true

        -- Deshabilitar TODOS los diagnostics de este buffer (más simple que
        -- filtrar por ns_id del cliente — el ns_id que devuelve get_namespace
        -- a veces no matchea el ns real usado por cssls al publish).
        -- Como contrapartida: si en el futuro querés diagnostics de algún
        -- otro tool en este mismo buffer, hay que afinar este filtro.
        vim.diagnostic.enable(false, { bufnr = bufnr })

        -- Reset de diagnostics existentes (los que ya publicó cssls antes
        -- de que disparara LspAttach).
        vim.diagnostic.reset(nil, bufnr)

        vim.notify("GTK CSS detectado: diagnósticos desactivados en este buffer", vim.log.levels.DEBUG)
    end,
})
