vim.pack.add {
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/mason-org/mason.nvim" },
  { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
  { src = "https://github.com/folke/lazydev.nvim" },
}

require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = { "lua_ls", "vtsls", "jsonls" },
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    require("lazydev").setup()
  end,
})

vim.diagnostic.config {
  -- virtual_lines = { current_line = true },
  virtual_text = true,
  float = { border = "rounded", focusable = true, auto = true },
  severity_sort = true,
  underline = { severity = { min = vim.diagnostic.severity.HINT } },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ", -- 
      [vim.diagnostic.severity.WARN] = "", -- 
      [vim.diagnostic.severity.HINT] = "󰛩 ", -- 
      [vim.diagnostic.severity.INFO] = "󰙎", -- 
    },
  },
}
