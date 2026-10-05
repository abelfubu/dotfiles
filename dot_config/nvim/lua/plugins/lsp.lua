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

vim.lsp.config("eslint", {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {
      "eslint.config.js",
      "eslint.config.mjs",
      "eslint.config.cjs",
      ".eslintrc.json",
      ".eslintrc.js",
      ".eslintrc.cjs",
    })

    if root then
      on_dir(root)
    end
  end,
  settings = {
    workingDirectory = { mode = "auto" },
  },
})

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
    opts = {
      -- lazydev is only for the Neovim config; projects manage lua_ls themselves
      enabled = function(root_dir)
        return root_dir == vim.fn.stdpath "config"
      end,
    },
  },
}
