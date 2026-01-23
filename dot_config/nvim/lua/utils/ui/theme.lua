local M = {}

M.italic_overrides = {
  ["@keyword"] = { italic = true },
  ["@keyword.return"] = { italic = true },
  ["@keyword.conditional"] = { italic = true },
  ["@keyword.function"] = { italic = true },
  ["@keyword.type"] = { italic = true },
  ["@keyword.modifier"] = { italic = true },
  ["@keyword.exception"] = { italic = true },
  ["@comment"] = { italic = true },
  ["@boolean"] = { italic = true },
}

M.hl_overrides = {
  ["@punctuation.bracket"] = { fg = "#777777" },
  FloatTitle = { fg = "base0A", bg = "darker_black" },
  NormalFloat = { bg = "darker_black" },
  FloatBorder = { bg = "darker_black", fg = "darker_black" },
}

M.hl_add_italics = {
  Keyword = { italic = true },
}

M.hl_adds = {
  DiagnosticUnderlineError = { undercurl = true, sp = "#ff5370" },
  DiagnosticUnderlineWarn = { undercurl = true, sp = "#ffcb6b" },
  DiagnosticUnderlineInfo = { undercurl = true, sp = "#82aaff" },
  DiagnosticUnderlineHint = { undercurl = true, sp = "#c3e88d" },
  StatusItemIconBlueSp = { bg = "lightbg", fg = "blue" },
  StatusItemIconBlue = { bg = "blue", fg = "black2" },
  StatusItemDisabled = { fg = "grey", bg = "black" },
  StatusItemDisabledSp = { bg = "lightbg", fg = "black" },
  StatusLineIconYellow = { bg = "yellow", fg = "black2" },
  StatusLineIconYellowSp = { fg = "yellow", bg = "lightbg" },
  StatusLineIconGreen = { bg = "green", fg = "black2" },
  StatusLineIconGreenSp = { fg = "green", bg = "lightbg" },
  StatusLineIconOrange = { bg = "base0A", fg = "black2" },
  StatusLineIconOrangeSp = { fg = "base0A", bg = "lightbg" },
  NoiceCmdlinePopupBorder = { bg = "black", fg = "black" },
  NoiceCmdlinePopup = { bg = "black2" },
  NoiceCmdlinePopupBorderSearch = { bg = "black", fg = "black" },
  MiniFilesBorderModified = { fg = "darker_black", bg = "darker_black" },
  NoiceConfirmBorder = { bg = "darker_black", fg = "darker_black" },
  NoiceConfirm = { bg = "darker_black", fg = "darker_black" },
  SnacksPickerPreview = { bg = "black2" },
  SnacksPickerPreviewTitle = { bg = "black2" },
  SnacksPickerPreviewBorder = { bg = "black2", fg = "black2" },
}

--- @class HightlightOverridesOpts
--- @field italics boolean
--- @field transparency boolean
--- @param opts HightlightOverridesOpts
--- @return table
M.get_highlight_overrides = function(opts)
  return vim.tbl_extend(
    "force",
    opts.italics and M.italic_overrides or {},
    M.hl_overrides
  )
end

--- @param opts HightlightOverridesOpts
--- @return table
M.get_highlight_adds = function(opts)
  return vim.tbl_extend(
    "force",
    opts.italics and M.italic_adds or {},
    M.hl_adds
  )
end

--- @param opts HightlightOverridesOpts
--- @return table
M.get_theme = function(base_config, opts)
  return vim.tbl_extend("force", base_config, {
    transparency = opts.transparency,
    hl_override = M.get_highlight_overrides(opts),
    hl_add = M.get_highlight_adds(opts),
  })
end

return M
