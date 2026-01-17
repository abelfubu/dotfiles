local ui_utils = require "utils.ui.statusline_item"
local theme = require "utils.ui.theme"

local M = {}

M.base46 = theme.get_theme({
  theme = "obsidian-ember-light",
  theme_toggle = { "obsidian-ember-light", "obsidian-ember" },
}, { italics = false, transparency = false })

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
          color = "orange",
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
    bufwidth = 21,
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
      cmd = ":lua require('snacks').picker.files()",
    },
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
