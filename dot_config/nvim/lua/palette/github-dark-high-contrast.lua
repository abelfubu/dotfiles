local M = {}

M.color_overrides = {
  mocha = {
    rosewater = "#f0f3f6",
    flamingo = "#ffb1af",
    pink = "#ff9492",
    mauve = "#d2a8ff",

    red = "#ff9492",
    maroon = "#ffb1af",

    peach = "#ffa657",
    yellow = "#e3b341",

    green = "#3fb950",
    teal = "#39c5cf",

    sky = "#79c0ff",
    sapphire = "#58a6ff",
    blue = "#58a6ff",
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
      -- Comments
      Comment = { fg = C.overlay2 },
      ["@comment"] = { fg = C.overlay2 },

      -- Keywords
      Keyword = { fg = C.red },
      ["@keyword"] = { fg = C.red },
      ["@keyword.function"] = { fg = C.red },
      ["@keyword.return"] = { fg = C.red },

      -- Don't make operators as prominent as keywords
      Operator = { fg = C.text },
      ["@operator"] = { fg = C.text },
      ["@keyword.operator"] = { fg = C.text },

      -- Functions
      Function = { fg = C.mauve },
      ["@function"] = { fg = C.mauve },
      ["@function.call"] = { fg = C.mauve },
      ["@function.method"] = { fg = C.mauve },
      ["@function.method.call"] = { fg = C.mauve },

      -- Strings
      String = { fg = C.lavender },
      ["@string"] = { fg = C.lavender },

      -- Literals
      Number = { fg = C.blue },
      Boolean = { fg = C.blue },
      Constant = { fg = C.blue },

      ["@number"] = { fg = C.blue },
      ["@boolean"] = { fg = C.blue },
      ["@constant"] = { fg = C.blue },

      -- Types: less neon than Git diff green
      Type = { fg = "#7ee787" },
      ["@type"] = { fg = "#7ee787" },
      ["@type.builtin"] = { fg = "#7ee787" },

      -- Editor
      Normal = { fg = C.text, bg = C.base },
      CursorLine = { bg = C.surface0 },

      LineNr = { fg = C.overlay0 },
      CursorLineNr = { fg = C.text },

      Visual = { bg = C.surface2 },

      -- Git
      GitSignsAdd = { fg = C.green },
      GitSignsChange = { fg = C.blue },
      GitSignsDelete = { fg = C.red },
    }
  end,
}

return M
