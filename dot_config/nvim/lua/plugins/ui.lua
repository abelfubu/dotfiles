return {
  "nvim-lua/plenary.nvim",
  {
    "nvchad/ui",
    config = function()
      require "nvchad"
    end,
  },
  {
    "nvchad/base46",
    build = function()
      require("base46").load_all_highlights()
    end,
    keys = {
      {
        "-",
        function()
          local buf_name = vim.api.nvim_buf_get_name(0)
          local path = vim.fn.filereadable(buf_name) == 1 and buf_name
            or vim.fn.getcwd()
          require("mini.files").open(path)
          require("mini.files").reveal_cwd()
        end,
        desc = "Open Mini Files",
      },
      {
        "<leader>gt",
        function()
          require("base46").toggle_theme()
        end,
        remap = true,
        desc = "Toggle theme",
      },
    },
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = { "saghen/blink.cmp" },
  },
}
