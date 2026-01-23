return {
  {
    "nvim-mini/mini.files",
    opts = {},
    keys = {
      {
        "<leader>ub",
        function()
          require("utils.ui.breadcrumb").toggle()
        end,
        remap = true,
        desc = "Toggle breadcrumbs",
      },
    },
  },
  { "nvim-mini/mini.pairs", opts = {} },
  {
    "nvim-mini/mini.icons",
    config = function()
      require("mini.icons").setup()
      MiniIcons.mock_nvim_web_devicons()
      require("utils.ui.breadcrumb").setup()
    end,
  },
  { "nvim-mini/mini.ai", opts = {} },
  { "nvim-mini/mini.surround", opts = {} },
}
