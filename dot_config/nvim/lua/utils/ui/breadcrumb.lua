local M = {}

M.toggle = function()
  if vim.o.winbar == "" then
    vim.o.winbar = "%m  %{%v:lua.WinbarPath()%}"
  else
    vim.o.winbar = ""
  end
end

M.setup = function(opts)
  opts = opts or {}

  _G.WinbarPath = function()
    if vim.bo.buftype ~= "" then
      return ""
    end

    local icons = require "mini.icons"
    local filename = vim.fn.expand "%:t"
    local filepath = vim.fn.fnamemodify(vim.fn.expand "%", ":.")

    -- Get file icon and highlight
    local file_icon, file_hl = icons.get("file", filename)
    file_icon = file_icon or ""
    file_hl = file_hl or "Normal"

    -- Get folder icon
    local folder_icon = icons.get("directory", "folder")
    folder_icon = folder_icon or ""

    -- Split path into parts
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

    return " " .. breadcrumb
  end

  vim.o.winbar = "%m  %{%v:lua.WinbarPath()%}"
end

return M
