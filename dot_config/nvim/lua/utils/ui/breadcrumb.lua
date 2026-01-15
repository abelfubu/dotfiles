local M = {}

M.show_breadcrumbs = false

M.filter_filetypes = {
  "oil",
  "help",
}

M.toggle = function()
  M.show_breadcrumbs = not M.show_breadcrumbs

  if M.show_breadcrumbs then
    print "Breadcrumbs enabled"
    vim.wo.winbar = M.winbar_path()
  else
    print "Breadcrumbs disabled"
    vim.wo.winbar = ""
  end
end

M.winbar_path = function()
  if vim.bo.buftype ~= "" then
    return ""
  end

  local icons = require "mini.icons"

  local filename = vim.fn.expand "%:t"
  local filepath = vim.fn.fnamemodify(vim.fn.expand "%", ":.")
  local file_icon, file_hl = icons.get("file", filename)
  local folder_icon = icons.get("directory", "folder")
  local parts = vim.split(filepath, "/", { plain = true })

  local breadcrumb = ""
  for i = 1, #parts - 1 do
    breadcrumb = breadcrumb
      .. folder_icon
      .. " "
      .. parts[i]
      .. " "
      .. "%#Normal#  "
  end

  if #parts > 0 then
    breadcrumb = breadcrumb
      .. string.format("%%#%s#%s%%* %s", file_hl, file_icon, parts[#parts])
  end

  return "    " .. breadcrumb
end

M.setup = function()
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("breadcrumb_winbar", { clear = true }),
    callback = function(args)
      if not M.show_breadcrumbs then
        vim.wo.winbar = ""
        return
      end
      -- Filter filetypes
      if vim.tbl_contains(M.filter_filetypes, vim.bo[args.buf].filetype) then
        vim.wo.winbar = ""
        return
      end
      -- Do not show winbar for single file in cwd
      local filepath = vim.fn.fnamemodify(vim.fn.expand "%", ":.")
      if not filepath or filepath == "" then
        vim.wo.winbar = ""
        return
      end

      local parts = vim.split(filepath, "/", { plain = true })
      if #parts == 1 then
        vim.wo.winbar = ""
        return
      end
      vim.wo.winbar = M.winbar_path()
    end,
  })
end

return M
