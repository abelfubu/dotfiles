vim.keymap.set({ "n", "v" }, "g.", function()
  vim.lsp.buf.code_action {
    filter = function(action)
      return action.disabled == nil
    end,
  }
end, { remap = true, desc = "Code actions" })

vim.keymap.set({ "n", "v" }, ";", ":", { noremap = true })
vim.keymap.set({ "n", "v" }, ":", ";", { noremap = true })

vim.keymap.set(
  { "n", "v" },
  "gd",
  "<C-]>",
  { remap = true, desc = "Code go to definition" }
)

vim.keymap.set(
  { "n", "v" },
  "gd",
  "<C-]>",
  { remap = true, desc = "Code go to definition" }
)

vim.keymap.set(
  { "n", "v" },
  "gvd",
  ":vsplit<CR><C-w>l<C-]>",
  { remap = true, desc = "Code go to definition" }
)

vim.keymap.set("n", "<D-s>", function()
  vim.cmd [[:w]]
end, { desc = "write buffer" })
vim.keymap.set("n", "L", function()
  vim.cmd [[:bn]]
end, { desc = "Next buffer" })
vim.keymap.set("n", "H", function()
  vim.cmd [[:bp]]
end, { desc = "Previous buffer" })

-- Window
vim.keymap.set(
  "n",
  "<C-h>",
  "<C-w>h",
  { desc = "Move window left", remap = true }
)
vim.keymap.set(
  "n",
  "<D-l>",
  "<C-w>l",
  { desc = "Move window right", remap = true }
)
vim.keymap.set(
  "n",
  "<D-j>",
  "<C-w>j",
  { desc = "Move window down", remap = true }
)
vim.keymap.set(
  "n",
  "<D-k>",
  "<C-w>k",
  { desc = "Move window up", remap = true }
)

-- Better ESC
vim.keymap.set({ "i", "n", "s" }, "<esc>", function()
  vim.cmd "noh"
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- Buffers
vim.keymap.set("n", "<leader>bo", function()
  local current_buf = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= current_buf and vim.api.nvim_buf_is_loaded(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end, { desc = "Close all other buffers" })

vim.keymap.set("n", "<leader>bn", function()
  vim.cmd [[bn]]
end, { desc = "Toggle buffer" })

vim.keymap.set("n", "<leader>bd", function()
  vim.cmd [[bd]]
end, { desc = "Delete buffer" })

-- Diagnostics
local diagnostic_goto = function(count, severity)
  return function()
    vim.diagnostic.jump {
      count = count,
      severity = vim.diagnostic.severity[severity] or nil,
      on_jump = vim.diagnostic.open_float,
    }
  end
end

vim.keymap.set(
  "n",
  "<leader>cd",
  vim.diagnostic.open_float,
  { desc = "Line Diagnostics" }
)
vim.keymap.set("n", "]d", diagnostic_goto(1), { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", diagnostic_goto(-1), { desc = "Prev Diagnostic" })
vim.keymap.set("n", "]e", diagnostic_goto(1, "ERROR"), { desc = "Next Error" })
vim.keymap.set("n", "[e", diagnostic_goto(-1, "ERROR"), { desc = "Prev Error" })
vim.keymap.set("n", "]w", diagnostic_goto(1, "WARN"), { desc = "Next Warning" })
vim.keymap.set(
  "n",
  "[w",
  diagnostic_goto(-1, "WARN"),
  { desc = "Prev Warning" }
)
vim.keymap.set("n", "H", "<cmd>bprev<CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "L", "<cmd>bnext<CR>", { desc = "Next Buffer" })
