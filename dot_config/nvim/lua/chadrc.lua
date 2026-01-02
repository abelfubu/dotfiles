local utils = require("nvchad.stl.utils").separators.round

local M = {}

M.base46 = {
  theme = "everforest",
  transparency = true,
  theme_toggle = { "flexoki-light", "everforest" },
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
    TbBufOff = { fg = "lightbg" },
    TbBufOn = { fg = "blue" },
  },
  hl_add = {
    Keyword = { italic = true },
    MiniPickMatchCurrent = { bg = "red", fg = "black" },
    DiagnosticUnderlineError = { undercurl = true, sp = "#ff5370" },
    DiagnosticUnderlineWarn = { undercurl = true, sp = "#ffcb6b" },
    DiagnosticUnderlineInfo = { undercurl = true, sp = "#82aaff" },
    DiagnosticUnderlineHint = { undercurl = true, sp = "#c3e88d" },
    RecordingSp = { bg = "lightbg", fg = "blue" },
    RecordingBg = { bg = "blue", fg = "black2" },
    StatusItemDisabled = { fg = "grey", bg = "black" },
    StatusItemDisabledSp = { bg = "lightbg", fg = "black" },
    FormatEnabled = { bg = "green", fg = "black2" },
    FormatEnabledSp = { fg = "green", bg = "lightbg" },
    OrganizeImportsEnabled = { bg = "orange", fg = "black2" },
    OrganizeImportsEnabledSp = { fg = "orange", bg = "lightbg" },
  },
}

M.ui = {
  statusline = {
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
        if rec ~= "" then
          local icon = "%#RecordingBg#" .. "󰄀 "
          local name = "%#St_cwd_text#" .. " Register @" .. rec .. " "
          return ("%#RecordingSp#" .. utils.left .. icon .. name)
        end
        return ""
      end,
      format = function()
        local color = _G.format_on_save and "%#FormatEnabled#"
          or "%#StatusItemDisabled#"
        local icon = color .. " "
        local name = "%#St_cwd_text#" .. " format "
        local separator_color = _G.format_on_save and "%#FormatEnabledSp#"
          or "%#StatusItemDisabledSp#"
        return (separator_color .. utils.left .. icon .. name)
      end,
      organizeImports = function()
        local color = _G.organize_imports_on_save
            and "%#OrganizeImportsEnabled#"
          or "%#StatusItemDisabled#"
        local icon = color .. " "
        local name = "%#St_cwd_text#" .. " imports "
        local separator_color = _G.organize_imports_on_save
            and "%#OrganizeImportsEnabledSp#"
          or "%#StatusItemDisabledSp#"
        return (separator_color .. utils.left .. icon .. name)
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
