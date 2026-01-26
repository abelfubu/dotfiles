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

M.close_other_buffers = function()
  local zen = require "snacks.zen"
  local open = not zen.win.closed

  if open then
    zen.win:close { buf = true }
  end

  local current_buf = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current_buf then
      vim.api.nvim_buf_delete(buf, {})
    end
  end

  if open then
    zen.zen()
  end
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
