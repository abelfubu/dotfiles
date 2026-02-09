vim.diagnostic.config {
  -- virtual_lines = { current_line = true },
  float = {
    border = "rounded",
    focusable = true,
    auto = true,
    source = "if_many",
  },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ", -- 
      [vim.diagnostic.severity.WARN] = "", -- 
      [vim.diagnostic.severity.HINT] = "󰛩 ", -- 
      [vim.diagnostic.severity.INFO] = "󰙎", -- 
    },
  },
  underline = { severity = { min = vim.diagnostic.severity.HINT } },
  virtual_text = false,
}

return {
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      { "neovim/nvim-lspconfig" },
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "vtsls",
        "jsonls",
        "postgres_lsp",
        "eslint",
      },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    opts = {},
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    opts = {},
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {},
  },
}
