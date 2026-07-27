return {
  {
    "dlyongemallo/diffview-plus.nvim",
    dependencies = "rickhowe/diffchar.vim",
    version = "*",
    lazy = false,
    opts = {
      show_help_hints = false,
      hide_merge_artifacts = true,
      clean_up_buffers = true,
      auto_close_on_empty = true,
      enhanced_diff_hl = true,
      diffopt = { algorithm = "histogram" },
      file_panel = {
        win_config = {
          width = 60,
        },
      },
      hooks = {
        view_enter = function()
          pcall(require("utils.ui.breadcrumb").disable)
        end,
        view_leave = function()
          pcall(require("utils.ui.breadcrumb").enable)
        end,
      },
    },
    keys = {
      {
        "<leader>do",
        function()
          require("diffview").open {}
        end,
        desc = "DiffView Open",
      },
      {
        "<leader>dt",
        function()
          require("diffview").toggle {}
        end,
        desc = "DiffView Toggle",
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = false,
      on_attach = function(bufnr)
        local gitsigns = require "gitsigns"

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal { "]c", bang = true }
          else
            gitsigns.nav_hunk "next"
          end
        end)

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal { "[c", bang = true }
          else
            gitsigns.nav_hunk "prev"
          end
        end)

        -- Actions
        map("n", "<leader>hs", gitsigns.stage_hunk)
        map("n", "<leader>hr", gitsigns.reset_hunk)

        map("v", "<leader>hs", function()
          gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
        end)

        map("v", "<leader>hr", function()
          gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
        end)

        map("n", "<leader>hS", gitsigns.stage_buffer)
        map("n", "<leader>hR", gitsigns.reset_buffer)
        map("n", "<leader>hp", gitsigns.preview_hunk)
        map("n", "<leader>hi", gitsigns.preview_hunk_inline)

        map("n", "<leader>hb", function()
          gitsigns.blame_line { full = true }
        end)

        map("n", "<leader>hd", gitsigns.diffthis)

        map("n", "<leader>hD", function()
          gitsigns.diffthis "~"
        end)

        map("n", "<leader>hQ", function()
          gitsigns.setqflist "all"
        end)
        map("n", "<leader>hq", gitsigns.setqflist)

        -- Toggles
        map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
        map("n", "<leader>tw", gitsigns.toggle_word_diff)

        -- Text object
        map({ "o", "x" }, "ih", gitsigns.select_hunk)
      end,
    },
  },
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    opts = {
      picker = "snacks",
      enable_builtin = true,
    },
    keys = {
      {
        "<leader>oi",
        "<CMD>Octo issue list<CR>",
        desc = "List GitHub Issues",
      },
      {
        "<leader>op",
        "<CMD>Octo pr list<CR>",
        desc = "List GitHub PullRequests",
      },
      {
        "<leader>od",
        "<CMD>Octo discussion list<CR>",
        desc = "List GitHub Discussions",
      },
      {
        "<leader>on",
        "<CMD>Octo notification list<CR>",
        desc = "List GitHub Notifications",
      },
      {
        "<leader>os",
        function()
          require("octo.utils").create_base_search_command {
            include_current_repo = true,
          }
        end,
        desc = "Search GitHub",
      },
    },
  },
}
