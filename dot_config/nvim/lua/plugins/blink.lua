vim.pack.add({
  {
    src = "https://github.com/saghen/blink.cmp",
    version = vim.version.range("1.*"),
  },
})

require("blink.cmp").setup({
  cmdline = { enabled = true },
  appearance = { nerd_font_variant = "normal" },
  fuzzy = { implementation = "prefer_rust" },
  -- sources = { default = { "lsp", "snippets", "buffer", "path" } },

  keymap = {
    preset = "enter",
    ["<D-Space>"] = { "show" },
  },

  completion = {
    ghost_text = { enabled = true },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      window = { border = "single" },
    },

    -- from nvchad/ui plugin
    -- exporting the ui config of nvchad blink menu
    -- helps non nvchad users
    menu = require("nvchad.blink").menu,
  },
})
