return {
  {
    "arborist-ts/arborist.nvim",
    lazy = false,
    config = function()
      require("arborist").setup {
        auto_install = false,
        parser_dir = vim.fn.stdpath "data" .. "/treesitter",
      }
    end,
  },
}
