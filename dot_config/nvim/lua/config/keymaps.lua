local map = vim.keymap.set
local helpers = require "utils.nvim.helpers"

-- Center screen when jumping
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map(
  "t",
  "<Esc><Esc>",
  "<C-\\><C-n>",
  { desc = "Enter normal mode on terminal" }
)

-- Remappings
map({ "n", "v" }, ";", ":", { noremap = true })
map({ "n", "v" }, ":", ";", { noremap = true })

-- Toggle relative number
map(
  "n",
  "<leader>ur",
  helpers.toggle_relative_number,
  { desc = "Toggle relative number" }
)

-- sort only selection in visual mode
map("v", "<leader>so", ":sort<CR>", {
  desc = "Sort lines",
})

map("n", "<C-s>", helpers.write, { desc = "write buffer" })
map("n", "<leader>|", ":vsplit<CR>", { desc = "Vertical split", silent = true })
map("n", "<leader>x", ":close<CR>", { desc = "Close split", silent = true })

-- Better ESC
map(
  { "i", "n", "s" },
  "<esc>",
  helpers.better_escape,
  { expr = true, desc = "Escape and Clear hlsearch" }
)

-- Buffers
map(
  "n",
  "<leader>bo",
  helpers.close_other_buffers,
  { desc = "Close all other buffers" }
)

-- Breadcrumb
map("n", "<leader>ub", function()
  require("utils.ui.breadcrumb").toggle()
end, { remap = true, desc = "Toggle breadcrumbs" })

map("n", "<leader>bd", helpers.delete_buffer, { desc = "Delete buffer" })

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", helpers.diagnostic_goto(1), { desc = "Next Diagnostic" })
map("n", "[d", helpers.diagnostic_goto(-1), { desc = "Prev Diagnostic" })
map("n", "]e", helpers.diagnostic_goto(1, "ERROR"), { desc = "Next Error" })
map("n", "[e", helpers.diagnostic_goto(-1, "ERROR"), { desc = "Prev Error" })
map("n", "]w", helpers.diagnostic_goto(1, "WARN"), { desc = "Next Warning" })
map("n", "[w", helpers.diagnostic_goto(-1, "WARN"), { desc = "Prev Warning" })

-- Editor
vim.keymap.set(
  "n",
  "<leader>fo",
  require("utils.editor.core").toggle_organize,
  { desc = "Toggle organizeImports on save" }
)

vim.keymap.set(
  "n",
  "<leader>fm",
  require("utils.editor.core").toggle_format,
  { desc = "Toggle format on save" }
)

vim.keymap.set({ "n", "v" }, "g.", function()
  vim.lsp.buf.code_action {
    filter = function(action)
      return action.disabled == nil
    end,
  }
end, {
  remap = true,
  desc = "Code actions",
})

-- Tabs
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close tab" })
map("n", "<leader>ta", ":tabonly<CR>", { desc = "Close all other tabs" })
map("n", "<C-Tab>", "gt", { noremap = true, desc = "Next tab" })
map("n", "<C-S-Tab>", "gT", { noremap = true, desc = "Previous tab" })
