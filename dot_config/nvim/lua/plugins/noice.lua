return {
  { "https://github.com/MunifTanjim/nui.nvim" },
  {
    "https://github.com/folke/noice.nvim",
    enabled = false,
    opts = {
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
    },
  },
}
