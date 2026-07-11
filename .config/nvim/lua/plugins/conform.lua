return {
  "stevearc/conform.nvim",
  keys = {
    { "<leader>f", function() require("conform").format({ timeout_ms = 3000, lsp_format = "fallback" }) end, desc = "Format buffer" },
  },
  cmd = { "ConformInfo" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        markdown = { "prettier" },
      },
    })
  end,
}
