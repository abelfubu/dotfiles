vim.pack.add { "https://github.com/nvchad/ui" }
vim.pack.add { "https://github.com/nvim-lua/plenary.nvim" }
vim.pack.add { "https://github.com/nvchad/base46" }
vim.pack.add { "https://github.com/nvchad/volt" }

require("base46").load_all_highlights()
require "nvchad"

vim.keymap.set("n", "gt", function()
  require("base46").toggle_theme()
end, { remap = true, desc = "Toggle theme" })

vim.keymap.set("n", "<leader>th", function()
  require("nvchad.themes").open()
end, { remap = true, desc = "Toggle theme" })
