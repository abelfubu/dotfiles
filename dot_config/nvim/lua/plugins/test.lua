vim.pack.add {
  { src = "https://github.com/antoinemadec/FixCursorHold.nvim" },
  { src = "https://github.com/nvim-neotest/nvim-nio" },
  { src = "https://github.com/nvim-neotest/neotest" },
  { src = "https://github.com/nvim-neotest/neotest-jest" },
  { src = "https://github.com/marilari88/neotest-vitest" },
  { src = "https://github.com/thenbe/neotest-playwright" },
}

---@diagnostic disable-next-line: missing-fields
require("neotest").setup {
  adapters = {
    require "neotest-jest",
    require "neotest-vitest",
    require("neotest-playwright").adapter {
      options = {
        persist_project_selection = true,
        enable_dynamic_test_discovery = true,
      },
    },
  },
}

vim.keymap.set("n", "<leader>tr", function()
  require("neotest").run.run()
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>tt", function()
  require("neotest").run.run(vim.fn.expand "%")
end, { desc = "Run test file" })

vim.keymap.set("n", "<leader>to", function()
  require("neotest").output.open { enter = true }
end, { desc = "Open test output" })

vim.keymap.set("n", "<leader>tp", function()
  require("neotest").output_panel.open()
end, { desc = "Open test output panel" })

vim.keymap.set("n", "<leader>ts", function()
  require("neotest").summary.open()
end, { desc = "Open test summary panel" })
