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
  virtual_text = {
    source = "if_many",
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
}

_G.organize_imports_on_save = _G.organize_imports_on_save == nil and true
  or _G.organize_imports_on_save

vim.keymap.set("n", "<leader>fo", function()
  _G.organize_imports_on_save = not _G.organize_imports_on_save
  if _G.organize_imports_on_save then
    vim.notify "Enabled organizeImports on save"
  else
    vim.notify "Disabled organizeImports on save"
  end
end, { desc = "Toggle organizeImports on save" })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
  callback = function(params)
    if not _G.organize_imports_on_save then
      return
    end

    local ft = vim.bo.filetype:gsub("react$", "")
    if not vim.tbl_contains({ "javascript", "typescript" }, ft) then
      return
    end

    for _, command in ipairs { ".organizeImports" } do
      vim.lsp.buf_request_sync(params.buf, "workspace/executeCommand", {
        command = (ft .. command),
        arguments = { vim.api.nvim_buf_get_name(params.buf) },
      }, 3000)
    end
  end,
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
        "vtsls",
        "jsonls",
        "postgres_lsp",
        "eslint",
      },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {},
  },
}
