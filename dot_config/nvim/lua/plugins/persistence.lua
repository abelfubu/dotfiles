-- stylua: ignore 
return {
  "folke/persistence.nvim",
  opts = {},
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
    { "<leader>qp", function() require("persistence").select() end, desc = "Select session" },
    { "<leader>ql", function() require("persistence").load { last = true } end, desc = "Restore last session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save current session" },
    { "<leader>qq", function() vim.cmd [[:qa]] end, { desc = "Quit session" }, },
  },
}
