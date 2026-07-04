return {
  "nvim-lua/plenary.nvim",
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    enabled = true,
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup {
        options = {
          -- hide_nc_statusline = true,
          transparent = true,
        },
        groups = {
          all = {
            -- DiagnosticUnderlineError = { undercurl = true, sp = "#ff5370" },
            -- DiagnosticUnderlineWarn = { undercurl = true, sp = "#ffcb6b" },
            -- DiagnosticUnderlineInfo = { undercurl = true, sp = "#82aaff" },
            -- DiagnosticUnderlineHint = { undercurl = true, sp = "#c3e88d" },
            MiniFilesBorderModified = { fg = "orange" },
            -- SnacksPickerPreview = { bg = "bg1" },
            -- SnacksPickerPreviewTitle = { bg = "bg1" },
            -- SnacksPickerPreviewBorder = { bg = "bg1", fg = "bg1" },
            ["@punctuation.bracket"] = { fg = "#777777" },
            -- FloatTitle = { fg = "fg1", bg = "bg0" },
            -- NormalFloat = { bg = "bg0" },
            FloatBorder = { fg = "bg3" },
            -- SnacksPickerBorder = { bg = "bg1", fg = "bg1" },
            -- SnacksPicker = { bg = "bg0" },
            -- SnacksPickerFloatTitle = { fg = "fg1", bg = "bg0" },
          },
        },
      }

      vim.cmd "colorscheme github_dark_high_contrast"
    end,
  },
  -- {
  --   "nvchad/ui",
  --   config = function()
  --     require "nvchad"
  --   end,
  -- },
  -- {
  --   "nvchad/base46",
  --   build = function()
  --     require("base46").load_all_highlights()
  --   end,
  --   keys = {
  --   },
  -- },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
      settings = {
        save_on_toggle = true,
      },
    },
    keys = function()
      local keys = {
        {
          "<leader>ha",
          function()
            require("harpoon"):list():add()
          end,
          desc = "Harpoon File",
        },
        {
          "<leader>hx",
          function()
            require("harpoon"):list():clear()
          end,
          desc = "Harpoon File",
        },
        {
          "<leader>ho",
          require("utils.ui.harpoon").harpoon_picker,
          desc = "Harpoon Quick Menu",
        },
      }

      for i = 1, 9 do
        table.insert(keys, {
          "<leader>" .. i,
          function()
            require("harpoon"):list():select(i)
          end,
          desc = "Harpoon to File " .. i,
        })
      end
      return keys
    end,
  },
}
