return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require "dap"

      for _, adapterType in ipairs { "node", "chrome", "msedge" } do
        local pwaType = "pwa-" .. adapterType

        if not dap.adapters[pwaType] then
          dap.adapters[pwaType] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = {
              command = "js-debug-adapter",
              args = { "${port}" },
            },
          }
        end

        -- Define adapters without the "pwa-" prefix for VSCode compatibility
        if not dap.adapters[adapterType] then
          dap.adapters[adapterType] = function(cb, config)
            local nativeAdapter = dap.adapters[pwaType]

            config.type = pwaType

            if type(nativeAdapter) == "function" then
              nativeAdapter(cb, config)
            else
              cb(nativeAdapter)
            end
          end
        end
      end

      local js_filetypes =
        { "typescript", "javascript", "typescriptreact", "javascriptreact" }

      local vscode = require "dap.ext.vscode"
      vscode.type_to_filetypes["node"] = js_filetypes
      vscode.type_to_filetypes["pwa-node"] = js_filetypes

      for _, language in ipairs(js_filetypes) do
        if not dap.configurations[language] then
          local runtimeExecutable = nil
          if language:find "typescript" then
            runtimeExecutable = vim.fn.executable "tsx" == 1 and "tsx"
              or "ts-node"
          end
          dap.configurations[language] = {
            {
              type = "pwa-node",
              request = "launch",
              name = "Launch file",
              program = "${file}",
              cwd = "${workspaceFolder}",
              sourceMaps = true,
              runtimeExecutable = runtimeExecutable,
              skipFiles = {
                "<node_internals>/**",
                "node_modules/**",
              },
              resolveSourceMapLocations = {
                "${workspaceFolder}/**",
                "!**/node_modules/**",
              },
            },
            {
              type = "pwa-node",
              request = "attach",
              name = "Attach",
              processId = require("dap.utils").pick_process,
              cwd = "${workspaceFolder}",
              sourceMaps = true,
              runtimeExecutable = runtimeExecutable,
              skipFiles = {
                "<node_internals>/**",
                "node_modules/**",
              },
              resolveSourceMapLocations = {
                "${workspaceFolder}/**",
                "!**/node_modules/**",
              },
            },
          }
        end
      end

-- Set keymaps to control the debugger
-- stylua: ignore
local keys = {
	{ "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
	{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
	{ "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
	{ "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
	{ "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
	{ "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
	{ "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
	{ "<leader>dj", function() require("dap").down() end, desc = "Down" },
	{ "<leader>dk", function() require("dap").up() end, desc = "Up" },
	{ "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
	{ "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
	{ "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
	{ "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
	{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
	{ "<leader>ds", function() require("dap").session() end, desc = "Session" },
	{ "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
	{ "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
}

      for _, keymap in ipairs(keys) do
        vim.keymap.set(
          keymap.mode or "n",
          keymap[1],
          keymap[2],
          { desc = keymap.desc, remap = true }
        )
      end

      -- signs for breakpoints with nerd fonts
      -- DapBreakpoint = ""

      vim.fn.sign_define(
        "DapBreakpoint",
        { text = " ", texthl = "GutterMarksLocal", linehl = "", numhl = "" }
      )
      vim.fn.sign_define(
        "DapBreakpointCondition",
        { text = " ", texthl = "GutterMarksGlobal", linehl = "", numhl = "" }
      )
      vim.fn.sign_define("DapLogPoint", {
        text = " ",
        texthl = "GutterMarksSpecial",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define(
        "DapStopped",
        { text = " ", texthl = "GutterMarksLocal", linehl = "", numhl = "" }
      )
      vim.fn.sign_define(
        "DapBreakpointRejected",
        { text = " ", texthl = "GutterMarksLocal", linehl = "", numhl = "" }
      )
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {},
  },
  { "theHamsta/nvim-dap-virtual-text", opts = {} },
}
