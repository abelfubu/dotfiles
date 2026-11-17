return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      preview = {
        enable = true,
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
