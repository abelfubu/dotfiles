_G.format_on_save = _G.format_on_save == nil and true or _G.format_on_save
vim.keymap.set("n", "<leader>fm", function()
  _G.format_on_save = not _G.format_on_save
  if _G.format_on_save then
    vim.notify "Enabled format on save"
  else
    vim.notify "Disabled format on save"
  end
end, { desc = "Toggle format on save" })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*" },
  callback = function(params)
    if _G.format_on_save then
      require("conform").format { bufnr = params.buf }
    end
  end,
})

return {
  { 
		"stevearc/conform.nvim" ,
		opts = {
  default_format_opts = {
    timeout_ms = 3000,
    async = false,
    quiet = false,
    lsp_format = "fallback",
  },
  formatters_by_ft = {
    css = { "prettier" },
    html = { "prettier" },
    htmlangular = { "prettier" },
    javascript = { "prettier" },
    json = { "prettier" },
    lua = { "stylua" },
    sql = { "pg_format" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    -- cs = { "csharpier" },
  },
  format_on_save = nil,
  formatters = {
    injected = { options = { ignore_errors = true } },
  },
		}
	},
}

