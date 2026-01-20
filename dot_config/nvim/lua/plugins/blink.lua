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
      ["<Tab>"] = {
        "snippet_forward",
        function() -- sidekick next edit suggestion
          return require("sidekick").nes_jump_or_apply()
        end,
        function() -- if you are using Neovim's native inline completions
          return vim.lsp.inline_completion.get()
        end,
        "fallback",
      },
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
        draw = {
          padding = { 0, 1 },
          columns = { { "kind_icon" }, { "label" }, { "kind" } },
          components = {
            kind_icon = {
              text = function(ctx)
                local icons = require "nvchad.icons.lspkind"
                local icon = " " .. (icons[ctx.kind] or "󰈚") .. " "

                return icon
              end,
            },
            kind = {
              highlight = function()
                return "comment"
              end,
            },
          },
        },
      },
    },
  },
}
