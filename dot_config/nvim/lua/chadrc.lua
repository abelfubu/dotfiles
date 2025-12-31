local utils = require("nvchad.stl.utils").separators.round

local M = {}

M.base46 = {
  theme = "github_light",
  transparency = true,
  theme_toggle = { "monochrome", "github_light" },
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
  },
  hl_add = {
    Keyword = { italic = true },
    MiniPickMatchCurrent = { bg = "red", fg = "black" },
    DiagnosticUnderlineError = { undercurl = true, sp = "#ff5370" },
    DiagnosticUnderlineWarn = { undercurl = true, sp = "#ffcb6b" },
    DiagnosticUnderlineInfo = { undercurl = true, sp = "#82aaff" },
    DiagnosticUnderlineHint = { undercurl = true, sp = "#c3e88d" },
    RecordingSp = { bg = "grey", fg = "blue" },
    RecordingBg = { bg = "blue", fg = "black2" },
    RecordingFg = { bg = "black2", fg = "fg" },
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
      "fubuDiagnostics",
      "lsp",
      "cwd",
      "cursor",
      "recording",
    },
    modules = {
      recording = function()
        local rec = vim.fn.reg_recording()
        if rec ~= "" then
          local icon = "%#RecordingBg#" .. "󰄀 "
          local name = "%#RecordingFg#" .. " Register @" .. rec .. " "
          return ("%#RecordingSp#" .. utils.left .. icon .. name)
        end
        return ""
      end,
      fubuDiagnostics = function()
        if not rawget(vim, "lsp") then
          return ""
        end

        local err = #vim.diagnostic.get(
          vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0),
          { severity = vim.diagnostic.severity.ERROR }
        )
        local warn = #vim.diagnostic.get(
          vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0),
          { severity = vim.diagnostic.severity.WARN }
        )
        local hints = #vim.diagnostic.get(
          vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0),
          { severity = vim.diagnostic.severity.HINT }
        )
        local info = #vim.diagnostic.get(
          vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0),
          { severity = vim.diagnostic.severity.INFO }
        )

        err = (err and err > 0) and ("%#St_lspError#" .. "" .. err .. " ")
          or ""
        warn = (warn and warn > 0)
            and ("%#St_lspWarning#" .. "" .. warn .. " ")
          or ""
        hints = (hints and hints > 0)
            and ("%#St_lspHints#" .. "󰛩 " .. hints .. " ")
          or ""
        info = (info and info > 0)
            and ("%#St_lspInfo#" .. "󰙎" .. info .. " ")
          or ""

        return " " .. err .. warn .. hints .. info
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
