-- stylua: ignore 
return {
  "folke/persistence.nvim",
  opts = {},
  keys = {
    { "<leader>qs", function() require("persistence").load() end, },
    { "<leader>qS", function() require("persistence").select() end, },
    { "<leader>ql", function() require("persistence").load { last = true } end, },
    { "<leader>qd", function() require("persistence").stop() end, },
    { "<leader>qq", function() vim.cmd [[:qa]] end, { desc = "Quit session" }, },
  },
}
