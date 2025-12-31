vim.pack.add {
  { src = "https://github.com/stevearc/conform.nvim" },
}

require("conform").setup {
  default_format_opts = {
    timeout_ms = 3000,
    async = false,
    quiet = false,
    lsp_format = "fallback",
  },
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    css = { "prettier" },
    typescriptreact = { "prettier" },
    htmlangular = { "prettier" },
    cs = { "csharpier" },
  },
  format_on_save = {
    timeout_ms = 1000,
  },
  formatters = {
    injected = { options = { ignore_errors = true } },
  },
}
