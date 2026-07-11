return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "c", "lua", "vim", "vimdoc", "markdown", "markdown_inline", "c_sharp", "xml" },
      highlight = { enable = true },
    })
  end,
}
