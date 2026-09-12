-- ★言語追加時はここにサーバー名を追加するだけ
local servers = { "clangd", "marksman", "csharp_ls", "lemminx" }

return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "williamboman/mason-lspconfig.nvim" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("lspconfig") -- Load default configurations into vim.lsp.config

      for _, server in ipairs(servers) do
        local opts = { capabilities = capabilities }

        if server == "csharp_ls" then
          opts.filetypes = { "cs" }
          opts.root_markers = { "*.sln", "*.csproj", ".git" }
        end

        local default_cfg = vim.lsp.config[server]
        if default_cfg then
          vim.lsp.config(server, vim.tbl_deep_extend("force", default_cfg, opts))
        else
          vim.lsp.config(server, opts)
        end
      end

      -- mason-lspconfig v2+ automatically enables installed servers,
      -- but we can explicitly enable them here just in case.
      vim.lsp.enable(servers)
    end,
  }
}
