local M = {}

M.color_overrides = {
  mocha = {
    rosewater = "#ffb1af",
    flamingo = "#ffb1af",
    pink = "#ff9492",
    mauve = "#e2c5ff",

    red = "#ff9492",
    maroon = "#ffb1af",

    peach = "#ffb757",
    yellow = "#f0b72f",

    green = "#26cd4d",
    teal = "#33b3ae",

    sky = "#71b7ff",
    sapphire = "#409eff",
    blue = "#409eff",
    lavender = "#a5d6ff",

    text = "#f0f3f6",
    subtext1 = "#d9dee3",
    subtext0 = "#bdc4cc",

    overlay2 = "#9ea7b3",
    overlay1 = "#7a828e",
    overlay0 = "#525964",

    surface2 = "#3d444d",
    surface1 = "#272b33",
    surface0 = "#1a1f24",

    base = "#0a0c10",
    mantle = "#07090c",
    crust = "#010409",
  },
}

M.highlight_overrides = {
  mocha = function(C)
    return {
      Comment = { fg = C.overlay2 },
      ["@comment"] = { fg = C.overlay2 },

      Keyword = { fg = C.red },
      ["@keyword"] = { fg = C.red },
      ["@keyword.function"] = { fg = C.red },
      ["@keyword.return"] = { fg = C.red },
      ["@keyword.operator"] = { fg = C.red },

      Function = { fg = C.mauve },
      ["@function"] = { fg = C.mauve },
      ["@function.call"] = { fg = C.mauve },
      ["@function.method"] = { fg = C.mauve },
      ["@function.method.call"] = { fg = C.mauve },

      String = { fg = C.lavender },
      ["@string"] = { fg = C.lavender },

      Number = { fg = C.blue },
      Boolean = { fg = C.blue },
      Constant = { fg = C.blue },

      ["@number"] = { fg = C.blue },
      ["@boolean"] = { fg = C.blue },
      ["@constant"] = { fg = C.blue },

      Type = { fg = C.green },
      ["@type"] = { fg = C.green },
      ["@type.builtin"] = { fg = C.green },

      Normal = { fg = C.text, bg = C.base },
      CursorLine = { bg = C.surface0 },

      LineNr = { fg = C.overlay0 },
      CursorLineNr = { fg = C.text },

      Visual = { bg = C.surface2 },

      GitSignsAdd = { fg = C.green },
      GitSignsChange = { fg = C.blue },
      GitSignsDelete = { fg = C.red },
    }
  end,
}

return M
