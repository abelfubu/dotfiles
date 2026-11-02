return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      preview = {
        -- Keep source editing unchanged; open the rendered split on demand.
        enable = false,
      },
    },
    keys = {
      {
        "<leader>mp",
        "<cmd>Markview splitToggle<cr>",
        desc = "Markdown preview split",
      },
    },
  },
}
