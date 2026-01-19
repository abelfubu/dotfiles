return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    config = function()
      require("nvim-treesitter.configs").setup {
        highlight = {
          enable = true,
          disable = {},
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        ensure_installed = {
          "typescript",
          "html",
          "angular",
          "javascript",
          "lua",
          "json",
          "yaml",
          "css",
          "http",
        },
        -- autotag = { enable = true },
      }
    end,
  },
}
