vim.pack.add({ "https://github.com/MunifTanjim/nui.nvim" })
vim.pack.add({ "https://github.com/folke/noice.nvim" })

require("noice").setup({
  presets = {
    lsp_doc_border = true,
    bottom_search = false,
  },
  cmdline = {
    view = "cmdline_popup",
    opts = {},
  },
  views = {
    hover = { scrollbar = false },
    cmdline_popup = {
      position = { row = "40%" },
      size = { width = "auto", height = "auto" },
    },
  },
})
