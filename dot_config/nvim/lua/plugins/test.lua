return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      {
        "mrcjkb/rustaceanvim",
        version = "^9",
        lazy = false,
      },
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
      "thenbe/neotest-playwright",
      "MisanthropicBit/neotest-busted",
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("neotest").setup {
        adapters = {
          require "neotest-jest",
          require "rustaceanvim.neotest",
          require "neotest-vitest",
          require "neotest-busted",
          require("neotest-playwright").adapter {
            options = {
              persist_project_selection = true,
              enable_dynamic_test_discovery = true,
            },
          },
        },
      }
    end,
    keys = {
      {
        "<leader>tr",
        function()
          require("neotest").run.run()
        end,
        desc = "Run nearest test",
      },
      {
        "<leader>td",
        function()
          require("neotest").run.run { strategy = "dap" }
        end,
        desc = "Run nearest test",
      },
      {
        "<leader>tt",
        function()
          require("neotest").run.run(vim.fn.expand "%")
        end,
        desc = "Run test file",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open { enter = true }
        end,
        desc = "Open test output",
      },
      {
        "<leader>tp",
        function()
          require("neotest").output_panel.open()
        end,
        desc = "Open test output panel",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.open()
        end,
        desc = "Open test summary panel",
      },
    },
  },
}
