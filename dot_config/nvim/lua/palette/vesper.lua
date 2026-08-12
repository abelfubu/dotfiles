local M = {}

M.color_overrides = {
  mocha = {
    rosewater = "#FFCFA8",
    flamingo = "#FFB86C",
    pink = "#D69094",
    mauve = "#A0A0A0",

    red = "#FF8080",
    maroon = "#FF8080",

    peach = "#FFC799",
    yellow = "#FFC799",

    green = "#99FFE4",
    teal = "#99FFE4",

    sky = "#A0A0A0",
    sapphire = "#A0A0A0",
    blue = "#A0A0A0",
    lavender = "#BBBBBB",

    text = "#FFFFFF",
    subtext1 = "#CCCCCC",
    subtext0 = "#A0A0A0",

    overlay2 = "#8B8B8B",
    overlay1 = "#777777",
    overlay0 = "#5C5C5C",

    surface2 = "#333333",
    surface1 = "#282828",
    surface0 = "#222222",

    base = "#101010",
    mantle = "#0D0D0D",
    crust = "#080808",
  },
}

M.highlight_overrides = {
  mocha = function(C)
    return {
      Normal = { fg = C.text, bg = C.base },
      NormalNC = { fg = C.text, bg = C.base },

      Comment = { fg = C.overlay0, style = { "italic" } },

      Identifier = { fg = C.text },
      ["@variable"] = { fg = C.text },
      ["@variable.member"] = { fg = C.text },
      ["@property"] = { fg = C.text },

      Function = { fg = C.text },
      ["@function"] = { fg = C.text },
      ["@function.call"] = { fg = C.text },
      ["@function.method"] = { fg = C.text },
      ["@function.method.call"] = { fg = C.text },

      Keyword = { fg = C.peach },
      ["@keyword"] = { fg = C.peach },
      ["@keyword.function"] = { fg = C.peach },
      ["@keyword.return"] = { fg = C.peach },
      ["@keyword.operator"] = { fg = C.peach },

      String = { fg = C.green },
      ["@string"] = { fg = C.green },
      ["@string.escape"] = { fg = C.peach },

      Number = { fg = C.peach },
      Boolean = { fg = C.peach },
      ["@number"] = { fg = C.peach },
      ["@boolean"] = { fg = C.peach },

      Type = { fg = C.subtext1 },
      ["@type"] = { fg = C.subtext1 },
      ["@type.builtin"] = { fg = C.peach },

      Operator = { fg = C.subtext0 },
      ["@operator"] = { fg = C.subtext0 },

      Constant = { fg = C.peach },
      ["@constant"] = { fg = C.peach },
      ["@constant.builtin"] = { fg = C.peach },

      CursorLine = { bg = C.surface0 },
      LineNr = { fg = C.surface2 },
      CursorLineNr = { fg = C.peach },
      Visual = { bg = C.surface2 },

      Search = { fg = C.base, bg = C.peach },
      IncSearch = { fg = C.base, bg = C.green },

      MatchParen = {
        fg = C.peach,
        style = { "bold" },
      },

      NormalFloat = {
        fg = C.text,
        bg = C.mantle,
      },

      FloatBorder = {
        fg = C.surface2,
        bg = C.mantle,
      },

      Pmenu = {
        fg = C.subtext1,
        bg = C.mantle,
      },

      PmenuSel = {
        fg = C.text,
        bg = C.surface1,
      },
    }
  end,
}

return M
