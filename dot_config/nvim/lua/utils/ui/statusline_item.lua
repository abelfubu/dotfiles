local M = {}

local statusline_item_colors = {
  green = { hl = "%#StatusLineIconGreen#", sp = "%#StatusLineIconGreenSp#" },
  orange = { hl = "%#StatusLineIconOrange#", sp = "%#StatusLineIconOrangeSp#" },
  blue = { hl = "%#StatusItemIconBlue#", sp = "%#StatusItemIconBlueSp#" },
  yellow = { hl = "%#StatusLineIconYellow#", sp = "%#StatusLineIconYellowSp#" },
  disabled = { hl = "%#StatusItemDisabled#", sp = "%#StatusItemDisabledSp#" },
}

---@class StatusLineItem
---@field icon string
---@field text string
---@field color string
---@field enabled? boolean
---@field visible? boolean
local StatusLineItem = {}

local defaults = {
  visible = true,
  enabled = true,
  color = "green",
  icon = "x ",
  text = "statusline item",
}

function StatusLineItem:new(opts)
  local options = vim.tbl_deep_extend("force", defaults, opts or {})
  setmetatable(options, self)
  self.__index = self
  return options
end

function StatusLineItem:getSeparators()
  local config = require("nvconfig").ui.statusline
  local sep_style = config.separator_style
  local utils = require "nvchad.stl.utils"

  local sep_icons = utils.separators
  local separators = (type(sep_style) == "table" and sep_style)
    or sep_icons[sep_style]

  return {
    left = separators["left"],
    right = separators["right"],
  }
end

function StatusLineItem:getIcon()
  local separators = self:getSeparators()
  local current_color =
    statusline_item_colors[self.enabled and self.color or "disabled"]

  return (current_color.sp .. separators.left .. current_color.hl .. self.icon)
end

function StatusLineItem:getText()
  return "%#St_cwd_text#" .. " " .. self.text .. " "
end

---comment
---@param opts StatusLineItem
---@return string
M.create_statusline_item = function(opts)
  if opts.visible == false then
    return ""
  end

  local item = StatusLineItem:new(opts)
  local icon = item:getIcon()
  local text = item:getText()

  return icon .. text
end

return M
