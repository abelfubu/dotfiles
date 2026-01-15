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
    opts = {
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
      },
      float = {
        preview_split = "right",
      },
      keymaps = {
        ["q"] = { "actions.close", mode = "n" },
        ["l"] = { "actions.select", mode = "n" },
        ["<D-p>"] = {
          "actions.preview",
          opts = { vertical = true, split = "belowright" },
        },
      },
    },
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    },
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    lazy = false,
  },
}
