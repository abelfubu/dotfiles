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
  TbBufOff = { fg = "grey" },
  TbBufOn = { fg = "blue" },
  FloatTitle = { fg = "orange", bg = "darker_black", bold = true },
  NormalFloat = { bg = "darker_black" },
  FloatBorder = { bg = "darker_black", fg = "darker_black" },
}

M.hl_add_italics = {
  Keyword = { italic = true },
}

M.hl_adds = {
  MiniPickMatchCurrent = { bg = "red", fg = "black" },
  DiagnosticUnderlineError = { undercurl = true, sp = "#ff5370" },
  DiagnosticUnderlineWarn = { undercurl = true, sp = "#ffcb6b" },
  DiagnosticUnderlineInfo = { undercurl = true, sp = "#82aaff" },
  DiagnosticUnderlineHint = { undercurl = true, sp = "#c3e88d" },
  StatusItemIconBlueSp = { bg = "lightbg", fg = "blue" },
  StatusItemIconBlue = { bg = "blue", fg = "black2" },
  StatusItemDisabled = { fg = "grey", bg = "black" },
  StatusItemDisabledSp = { bg = "lightbg", fg = "black" },
  StatusLineIconGreen = { bg = "green", fg = "black2" },
  StatusLineIconGreenSp = { fg = "green", bg = "lightbg" },
  StatusLineIconOrange = { bg = "orange", fg = "black2" },
  StatusLineIconOrangeSp = { fg = "orange", bg = "lightbg" },
  NoiceCmdlinePopupBorder = { bg = "black", fg = "black" },
  NoiceCmdlinePopupBorderSearch = { bg = "black", fg = "black" },
}

--- @class HightlightOverridesOpts
--- @field italics boolean
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

return M
