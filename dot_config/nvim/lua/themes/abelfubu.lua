-- Dark theme ported from custom VSCode theme
-- Author: Abel
local M = {}

-- UI / general colors
M.base_30 = {
  white = "#cad2c5",
  darker_black = "#181b21",
  black = "#1e222a",
  black2 = "#232831",
  one_bg = "#252a33",
  one_bg2 = "#2a303a",
  one_bg3 = "#303744",

  grey = "#404040",
  grey_fg = "#5a6374",
  grey_fg2 = "#6b7280",
  light_grey = "#8b949e",

  red = "#e67e80",
  baby_pink = "#e06c75",
  pink = "#d16d9e",

  line = "#2a303a",

  green = "#a7c080",
  vibrant_green = "#89d185",

  blue = "#7fbbb3",
  nord_blue = "#56b6c2",

  yellow = "#dbbc7f",
  sun = "#e5c07b",

  purple = "#d3c6aa",
  dark_purple = "#b180d7",

  teal = "#7fbbb3",
  orange = "#e69875",
  cyan = "#56b6c2",

  statusline_bg = "#232831",
  lightbg = "#2a303a",
  pmenu_bg = "#7fbbb3",
  folder_bg = "#7fbbb3",
}

-- Syntax / base16
M.base_16 = {
  base00 = "#1e222a", -- bg
  base01 = "#232831",
  base02 = "#2a303a",
  base03 = "#3c414d",
  base04 = "#5a6374",
  base05 = "#cad2c5", -- fg
  base06 = "#d3c6aa",
  base07 = "#ffffff",

  base08 = "#dbbc7f", -- yellow
  base09 = "#e69875", -- orange
  base0A = "#a7c080", -- green
  base0B = "#e67e80", -- red
  base0C = "#7fbbb3", -- cyan
  base0D = "#7fbbb3", -- blue
  base0E = "#e06c75", -- pink/red
  base0F = "#d3c6aa", -- purple
}

-- Small targeted overrides
M.polish_hl = {
  defaults = {
    Cursor = {
      bg = M.base_30.blue,
      fg = M.base_30.black,
    },
    CursorLine = {
      bg = "#232831",
    },
    CursorColumn = {
      bg = "#232831",
    },
    Visual = {
      bg = "#333841",
    },
    Search = {
      bg = "#515c6a",
      fg = M.base_30.white,
    },
    IncSearch = {
      bg = "#d3c6aa",
      fg = M.base_30.black,
    },
    Comment = {
      fg = "#708072",
      italic = true,
    },
  },
}

M.type = "dark"

M = require("base46").override_theme(M, "abelfubu")

return M
