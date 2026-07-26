return {
  "saghen/blink.cmp",
  version = "1.*",
  opts = {
    cmdline = { enabled = true },
    appearance = { nerd_font_variant = "normal" },
    fuzzy = { implementation = "prefer_rust" },
    sources = { default = { "lsp", "snippets", "buffer", "path" } },
    keymap = {
      preset = "enter",
      ["<D-Space>"] = { "show" },
    },
    completion = {
      accept = { auto_brackets = { enabled = false } },
      ghost_text = { enabled = true },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = { border = "single" },
      },
      menu = {
        scrollbar = false,
        border = "none",
      },
    },
  },
}
