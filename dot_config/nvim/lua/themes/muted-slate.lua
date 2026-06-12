local M = {}

M.base_30 = {
  white = "#c8ccd4",

  darker_black = "#14171c",
  black = "#1a1d23",
  black2 = "#1f232b",

  one_bg = "#252a33",
  one_bg2 = "#2a2f38",
  one_bg3 = "#313844",

  grey = "#5a6270",
  grey_fg = "#6b7280",
  grey_fg2 = "#7a8290",
  light_grey = "#8c95a3",

  red = "#e07a7a",
  baby_pink = "#c89a6e",

  pink = "#9a8fc4",
  line = "#2a2f38",

  green = "#7aa67a",
  vibrant_green = "#7fb3a8",

  blue = "#8aa9c9",
  nord_blue = "#7a9ec9",

  yellow = "#d4b06a",
  sun = "#d4b06a",

  purple = "#9a8fc4",
  dark_purple = "#8c81b6",

  teal = "#7fb3a8",
  orange = "#c89a6e",
  cyan = "#7fb3a8",

  statusline_bg = "#252a33",
  lightbg = "#2a2f38",

  pmenu_bg = "#8aa9c9",
  folder_bg = "#8aa9c9",
}

M.base_16 = {
  base00 = "#1a1d23", -- bg
  base01 = "#1f232b", -- panel
  base02 = "#252a33",
  base03 = "#6b7280", -- dim
  base04 = "#8c95a3",
  base05 = "#c8ccd4", -- fg
  base06 = "#d5d9df",
  base07 = "#e2e6eb",

  base08 = "#e07a7a", -- red
  base09 = "#c89a6e", -- orange/context
  base0A = "#d4b06a", -- yellow
  base0B = "#7aa67a", -- green
  base0C = "#7fb3a8", -- cyan/teal
  base0D = "#8aa9c9", -- blue/accent
  base0E = "#9a8fc4", -- purple
  base0F = "#5a6270", -- comments/done
}

M.type = "dark"

M = require("base46").override_theme(M, "muted_slate")

return M
