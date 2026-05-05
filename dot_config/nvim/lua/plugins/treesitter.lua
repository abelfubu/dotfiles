return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = false,
    build = ":TSUpdate",
  },
}
