local M = {}

M.toggle_relative_number = function()
  if vim.o.relativenumber then
    vim.o.relativenumber = false
  else
    vim.o.relativenumber = true
  end
end

M.write = function()
  vim.cmd [[:w]]
end

M.next_buffer = function()
  vim.cmd [[:bn]]
end

M.previous_buffer = function()
  vim.cmd [[:bp]]
end

M.delete_buffer = function()
  vim.cmd [[bd]]
end

M.stop_insert = function()
  vim.cmd.stopinsert()
end

M.better_escape = function()
  vim.cmd "noh"
  return "<esc>"
end

M.diagnostic_goto = function(count, severity)
  return function()
    vim.diagnostic.jump {
      count = count,
      severity = vim.diagnostic.severity[severity] or nil,
      -- on_jump = vim.diagnostic.open_float,
    }
  end
end

return M
