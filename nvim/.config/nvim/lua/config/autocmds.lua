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
