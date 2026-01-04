vim.pack.add {
  -- { src = "https://github.com/nvim-mini/mini.files" },
  -- { src = "https://github.com/nvim-mini/mini.pick" },
  { src = "https://github.com/nvim-mini/mini.pairs" },
  { src = "https://github.com/nvim-mini/mini.icons" },
  -- { src = "https://github.com/nvim-mini/mini.extra" },
  { src = "https://github.com/nvim-mini/mini.ai" },
  { src = "https://github.com/nvim-mini/mini.surround" },
}

-- require("mini.files").setup {}
-- require("mini.pick").setup {
--   window = {
--     config = function()
--       local height = math.floor(0.618 * vim.o.lines)
--       local width = math.floor(0.618 * vim.o.columns)
--       return {
--         anchor = "NW",
--         height = height,
--         width = width,
--         row = math.floor(0.5 * (vim.o.lines - height)),
--         col = math.floor(0.5 * (vim.o.columns - width)),
--       }
--     end,
--   },
-- }position = "right",
require("mini.icons").setup {}
require("mini.pairs").setup {}
-- require("mini.extra").setup {}
require("mini.ai").setup {}
require("mini.surround").setup {}
MiniIcons.mock_nvim_web_devicons()

-- Mini pick
-- vim.keymap.set(
--   "n",
--   "<D-p>",
--   MiniPick.builtin.files,
--   { desc = "Open pick files" }
-- )
-- vim.keymap.set(
--   "n",
--   "<Space><Space>",
--   MiniPick.builtin.files,
--   { desc = "Open pick files" }
-- )
-- vim.keymap.set(
--   "n",
--   "<leader>/",
--   MiniPick.builtin.grep_live,
--   { desc = "Open pick files" }
-- )
--
-- vim.keymap.set("n", "<leader>sb", function()
--   local wipeout_cur = function()
--     vim.api.nvim_buf_delete(MiniPick.get_picker_matches().current.bufnr, {})
--   end
--   local buffer_mappings = { wipeout = { char = "<C-d>", func = wipeout_cur } }
--   MiniPick.builtin.buffers({}, { mappings = buffer_mappings })
-- end, { desc = "Search buffers" })
--
-- vim.keymap.set(
--   "n",
--   "<leader>sh",
--   MiniPick.builtin.help,
--   { desc = "Search help" }
-- )
-- vim.keymap.set("n", "<leader>ss", function()
--   MiniExtra.pickers.lsp { scope = "document_symbol" }
-- end, { desc = "Search document symbols" })
-- vim.keymap.set(
--   "n",
--   "<leader>e",
--   MiniExtra.pickers.explorer,
--   { desc = "Search explorer" }
-- )
-- vim.keymap.set(
--   "n",
--   "<leader>sc",
--   MiniExtra.pickers.commands,
--   { desc = "Search commands" }
-- )
-- vim.keymap.set(
--   "n",
--   "<leader>sd",
--   MiniExtra.pickers.diagnostic,
--   { desc = "Search diagnostics" }
-- )
-- vim.keymap.set(
--   "n",
--   "<leader>sk",
--   MiniExtra.pickers.keymaps,
--   { desc = "Search keymaps" }
-- )
-- vim.keymap.set("n", "<leader>sw", function()
--   MiniExtra.pickers.lsp { scope = "workspace_symbol_live" }
-- end, { desc = "Search keymaps" })
-- vim.keymap.set("n", "<leader>sr", function()
--   MiniExtra.pickers.lsp { scope = "references" }
-- end, { desc = "Search keymaps" })

-- Mini files
-- vim.keymap.set("n", "-", function()
--   local buf_name = vim.api.nvim_buf_get_name(0)
--   local path = vim.fn.filereadable(buf_name) == 1 and buf_name
--     or vim.fn.getcwd()
--   require("mini.files").open(path)
--   require("mini.files").reveal_cwd()
-- end, { desc = "Open Mini Files" })
