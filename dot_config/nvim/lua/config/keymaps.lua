local map = vim.keymap.set
local helpers = require "utils.nvim.helpers"

-- Center screen when jumping
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

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

map(
  { "n", "v" },
  "gd",
  "<C-]>",
  { remap = true, desc = "Code go to definition" }
)

map(
  { "n", "v" },
  "gd",
  "<C-]>",
  { remap = true, desc = "Code go to definition" }
)

map(
  { "n", "v" },
  "gvd",
  ":vsplit<CR><C-w>l<C-]>",
  { remap = true, desc = "Code go to definition" }
)

map("n", "<C-s>", helpers.write, { desc = "write buffer" })
map("n", "L", helpers.next_buffer, { desc = "Next buffer" })
map("n", "H", helpers.previous_buffer, { desc = "Previous buffer" })
map("n", "<leader>|", ":vsplit<CR>", { desc = "Vertical split", silent = true })
map("n", "<leader>x", ":close<CR>", { desc = "Close split", silent = true })

-- Window
map("n", "<C-h>", function()
  require("smart-splits").move_cursor_left()
end, { desc = "Move window left", remap = true })
map("n", "<C-j>", function()
  require("smart-splits").move_cursor_down()
end, { desc = "Move window down", remap = true })
map("n", "<C-k>", function()
  require("smart-splits").move_cursor_up()
end, { desc = "Move window up", remap = true })
map("n", "<C-l>", function()
  require("smart-splits").move_cursor_right()
end, { desc = "Move window right", remap = true })

-- map("n", "<C-h>", "<C-w>h", { desc = "Move window left", remap = true })
-- map("n", "<C-j>", "<C-w>j", { desc = "Move window down", remap = true })
-- map("n", "<C-k>", "<C-w>k", { desc = "Move window up", remap = true })
-- map("n", "<C-l>", "<C-w>l", { desc = "Move window right", remap = true })

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

map("n", "<leader>bd", helpers.delete_buffer, { desc = "Delete buffer" })

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", helpers.diagnostic_goto(1), { desc = "Next Diagnostic" })
map("n", "[d", helpers.diagnostic_goto(-1), { desc = "Prev Diagnostic" })
map("n", "]e", helpers.diagnostic_goto(1, "ERROR"), { desc = "Next Error" })
map("n", "[e", helpers.diagnostic_goto(-1, "ERROR"), { desc = "Prev Error" })
map("n", "]w", helpers.diagnostic_goto(1, "WARN"), { desc = "Next Warning" })
map("n", "[w", helpers.diagnostic_goto(-1, "WARN"), { desc = "Prev Warning" })
map("n", "H", "<cmd>bprev<CR>", { desc = "Previous Buffer" })
map("n", "L", "<cmd>bnext<CR>", { desc = "Next Buffer" })

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
