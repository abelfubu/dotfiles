-- Light variant of Obsidian Ember theme
-- Credits to original https://github.com/Lvzitan/obsidian-ember-theme
local M = {}

M.base_30 = {
  white = "#1e1e1e",
  darker_black = "#ffffff",
  black = "#f5f5f5",
  black2 = "#eeeeee",
  one_bg = "#e8e8e8",
  one_bg2 = "#e0e0e0",
  one_bg3 = "#d8d8d8",
  grey = "#c8c8c8",
  grey_fg = "#b8b8b8",
  grey_fg2 = "#a8a8a8",
  light_grey = "#989898",
  red = "#d93d3d",
  baby_pink = "#c96b73",
  pink = "#b85865",
  line = "#e0e0e0",
  green = "#4d7acc",
  vibrant_green = "#5ba871",
  blue = "#989898",
  nord_blue = "#c8c8c8",
  yellow = "#d9a800",
  sun = "#c4a62f",
  purple = "#aaaaaa",
  dark_purple = "#9d3e71",
  teal = "#4d7acc",
  orange = "#cd6316",
  cyan = "#00a388",
  statusline_bg = "#ebebeb",
  lightbg = "#e5e5e5",
  pmenu_bg = "#e77726",
  folder_bg = "#cd6316",
}

M.base_16 = {
  base00 = "#f5f5f5",
  base01 = "#e8e8e8",
  base02 = "#e0e0e0",
  base03 = "#d8d8d8",
  base04 = "#2e2e2e",
  base05 = "#4a4a4a",
  base06 = "#2c2c2c",
  base07 = "#1e1e1e",
  base08 = "#ff8548",
  base09 = "#1e1e1e",
  base0A = "#ff8548",
  base0B = "#6a6a6a",
  base0C = "#2e2e2e",
  base0D = "#2e2e2e",
  base0E = "#1e1e1e",
  base0F = "#2e2e2e",
}

M.polish_hl = {
  cmp = {
    CmpItemAbbrMatch = {
      fg = M.base_16.base08,
    },
    CmpItemAbbrMatchDefault = {
      bold = true,
      fg = M.base_16.base08,
    },
  },
  defaults = {
    SpellBad = {
      sp = M.base_30.red,
    },
    Cursor = {
      bg = M.base_16.base08,
    },
    CursorColumn = {
      bg = M.base_16.base01,
    },
  },
}

M.type = "light"

M = require("base46").override_theme(M, "obsidian-ember-light")

return M
