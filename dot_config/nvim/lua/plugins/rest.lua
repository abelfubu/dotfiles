vim.pack.add { "https://github.com/mistweaverco/kulala.nvim" }

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "http", "rest" },
  callback = function(param)
    require("kulala").setup {
      global_keymaps = false,
      global_keymaps_prefix = "<leader>R",
      kulala_keymaps_prefix = "",
      ui = {
        display_mode = "float",
        win_opts = {
          wo = { foldmethod = "None" },
        },
      },
    }

    vim.keymap.set(
      "n",
      "<leader>rr",
      require("kulala").run,
      { desc = "Send request", buffer = param.buf }
    )

    vim.keymap.set(
      "n",
      "<leader>ra",
      require("kulala").run_all,
      { desc = "Send request", buffer = param.buf }
    )
  end,
})
