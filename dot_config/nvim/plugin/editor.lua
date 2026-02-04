local M = {}

M.opts = {
  format = true,
  organize = true,
}

M.toggle_format = function()
  M.opts.format = not M.opts.format
  vim.notify(
    string.format(
      "Format on save: %s",
      M.opts.format and "enabled" or "disabled"
    ),
    vim.log.levels.INFO
  )
end

M.toggle_organize = function()
  M.opts.organize = not M.opts.organize
  vim.notify(
    string.format(
      "Organize imports: %s",
      M.opts.organize and "enabled" or "disabled"
    ),
    vim.log.levels.INFO
  )
end

vim.keymap.set(
  "n",
  "<leader>fo",
  M.toggle_organize,
  { desc = "Toggle organizeImports on save" }
)
vim.keymap.set(
  "n",
  "<leader>fm",
  M.toggle_format,
  { desc = "Toggle format on save" }
)

vim.keymap.set({ "n", "v" }, "g.", function()
  vim.lsp.buf.code_action {
    filter = function(action)
      return action.disabled == nil
    end,
  }
end, {
  remap = true,
  desc = "Code actions",
})

return M
