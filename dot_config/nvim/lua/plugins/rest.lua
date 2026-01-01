vim.pack.add { "https://github.com/mistweaverco/kulala.nvim" }

require("kulala").setup {
  global_keymaps = true,
  global_keymaps_prefix = "<leader>r",
  kulala_keymaps_prefix = "",
  ui = {
    display_mode = "float",
    win_opts = {
      wo = { foldmethod = "None" },
    },
  },
}
