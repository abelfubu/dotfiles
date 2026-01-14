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
        "<leader>-",
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
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    },
    -- Optional dependencies
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },
}
