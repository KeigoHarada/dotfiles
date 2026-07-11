return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = { "c", "lua", "vim", "vimdoc", "markdown", "markdown_inline", "c_sharp", "xml" },
    })
  end,
}
