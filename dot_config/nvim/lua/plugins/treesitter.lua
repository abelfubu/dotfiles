return {
  {
    "arborist-ts/arborist.nvim",
    cmd = {
      "Arborist",
      "ArboristInstall",
      "ArboristUpdate",
      "ArboristRemove",
    },
    opts = {
      auto_install = false,
      parser_dir = vim.fn.stdpath "data" .. "/treesitter",
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
  },
}
