return {
  {
    "nvim-mini/mini.files",
    enabled = true,
    opts = {},
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
  -- { "nvim-mini/mini.statusline", opts = {} },
}
