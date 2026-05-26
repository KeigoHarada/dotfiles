-- インデント
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

-- 改行コード
vim.opt.fileformat = "unix"
vim.opt.fileformats = { "unix", "dos", "mac" }

-- 行番号
vim.opt.number = true

-- ファイルタイプ検出、プラグイン、インデントを有効か
vim.cmd("filetype plugin indent on")

-- neovimのシステムクリップボードを有効
vim.opt.clipboard:append('unnamedplus')
