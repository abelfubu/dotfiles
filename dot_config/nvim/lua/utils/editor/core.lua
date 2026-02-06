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

return M
