return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("fzf-lua").setup({})

    local map = vim.keymap.set
    local fzf = require("fzf-lua")

    -- ファイル・検索関連のマッピング
    map("n", "<leader>ff", fzf.files, { desc = "Fzf Files" })
    map("n", "<leader>fg", fzf.live_grep, { desc = "Fzf Live Grep" })
    map("n", "<leader>fb", fzf.buffers, { desc = "Fzf Buffers" })
    map("n", "<leader>fo", fzf.oldfiles, { desc = "Fzf Oldfiles" })
    map("n", "<leader>fh", fzf.help_tags, { desc = "Fzf Help Tags" })

    -- LSP関連のマッピング
    map("n", "gd", fzf.lsp_definitions, { desc = "LSP Definition" })
    map("n", "gr", fzf.lsp_references, { desc = "LSP References" })
  end,
}
