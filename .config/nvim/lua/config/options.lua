-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- インデント
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

-- True Colorの有効化 (Terminal.appでは無効化する)
if vim.env.TERM_PROGRAM ~= "Apple_Terminal" then
  vim.opt.termguicolors = true
end

-- 改行コード
vim.opt.fileformat = "unix"
vim.opt.fileformats = { "unix", "dos", "mac" }

-- 行番号
vim.opt.number = true

-- ファイルタイプ検出、プラグイン、インデントを有効か
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")

-- neovimのシステムクリップボードを有効
vim.opt.clipboard:append('unnamedplus')

-- ホットリロード --
vim.opt.autoread = true
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter"}, {
  pattern = "*",
  command = "checktime",
})

-- ペースト後に^Mを自動除去--
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[silent! %s/\r//g]])
    vim.fn.winrestview(save)
  end,
})

-- Diagnostics (エラーや警告) のショートカット --
vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = "Show line diagnostics" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
