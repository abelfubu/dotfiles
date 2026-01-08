local ui_utils = require "utils.ui.statusline_item"

local M = {}

M.statusline_item_colors = {
  green = { hl = "StatusLineIconGreen", sp = "StatusLineIconGreenSp" },
  orange = { hl = "StatusLineIconOrange", sp = "StatusLineIconOrangeSp" },
  blue = { hl = "StatusItemIconBlue", sp = "StatusItemIconBlueSp" },
  disabled = { hl = "StatusItemDisabled", sp = "StatusItemDisabledSp" },
}

M.base46 = {
  theme = "aylin",
  transparency = true,
  theme_toggle = { "flexoki-light", "aylin" },
  hl_override = {
    ["@keyword"] = { italic = true },
    ["@keyword.return"] = { italic = true },
    ["@keyword.conditional"] = { italic = true },
    ["@keyword.function"] = { italic = true },
    ["@keyword.type"] = { italic = true },
    ["@keyword.modifier"] = { italic = true },
    ["@keyword.exception"] = { italic = true },
    ["@comment"] = { italic = true },
    ["@boolean"] = { italic = true },
    ["@punctuation.bracket"] = { fg = "#777777" },
    TbBufOff = { fg = "grey" },
    TbBufOn = { fg = "blue" },
  },
  hl_add = {
    Keyword = { italic = true },
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
    GutterMarksLocal = { fg = "red" },
    GutterMarksGlobal = { fg = "green" },
    GutterMarksSpecial = { fg = "orange" },
  },
}

M.ui = {
  statusline = {
    separator_style = "block",
    order = {
      "mode",
      "file",
      "git",
      "%=",
      "lsp_msg",
      "%=",
      "diagnostics",
      "lsp",
      "cwd",
      "format",
      "organizeImports",
      "recording",
    },
    modules = {
      recording = function()
        local rec = vim.fn.reg_recording()

        return ui_utils.create_statusline_item {
          color = "blue",
          icon = "󰄀 ",
          text = "Register @" .. rec,
          visible = rec ~= "",
        }
      end,
      format = function()
        return ui_utils.create_statusline_item {
          color = "green",
          icon = " ",
          text = "format",
          enabled = _G.format_on_save,
        }
      end,
      organizeImports = function()
        return ui_utils.create_statusline_item {
          color = "orange",
          icon = " ",
          text = "imports",
          enabled = _G.organize_imports_on_save,
        }
      end,
    },
  },
  cmp = { style = "atom" },
  tabufline = {
    order = { "buffers", "tabs" },
    enabled = true,
    lazyload = false,
    tabufline_style = "default",
  },
}

M.lsp = { signature = false }

M.nvdash = {
  load_on_startup = true,
  header = {
    "                            ",
    "         abelfubu           ",
    "                            ",
  },

  buttons = {
    {
      txt = "  Restore Session",
      keys = "Spc q s",
      cmd = ":lua require('persistence').load()",
    },
    {
      txt = "  Find File",
      keys = "[Ctrl] P",
      cmd = ":lua MiniPick.builtin.files()",
    },

    -- Footer
    { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
    {
      txt = "  " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
      hl = "NvDashFooter",
      no_gap = true,
      content = "fit",
    },
    { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true },
  },
}

return M
