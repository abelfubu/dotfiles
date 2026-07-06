return {
  "nvim-lua/plenary.nvim",
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      float = {
        padding = 5,
        preview_split = "right",
      },
    },
    -- Optional dependencies
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    lazy = false,
  },
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
          transparent = true,
        },
        palettes = {
          github_dark_high_contrast = {
            -- Tokyo Night main colors
            black = { base = "#16161e", bright = "#292e42" },
            red = { base = "#db4b4b", bright = "#db4b4b" },
            green = { base = "#73daca", bright = "#9ece6a" },
            yellow = { base = "#e0af68", bright = "#ff9e64" },
            blue = { base = "#7aa2f7", bright = "#7dcfff" },
            magenta = { base = "#9d7cd8", bright = "#bb9af7" },
            cyan = { base = "#2ac3de", bright = "#89ddff" },
            white = { base = "#c0caf5", bright = "#a9b1d6" },
            orange = "#ff9e64",
            comment = "#565f89",
            bg0 = "#16161e",
            bg1 = "#16161e",
            bg2 = "#292e42",
            bg3 = "#394b70",
            bg4 = "#292e42",
            fg0 = "#c0caf5",
            fg1 = "#a9b1d6",
            fg2 = "#737aa2",
            fg3 = "#565f89",
            sel0 = "#283457",
            sel1 = "#283457",
            sel2 = "#283457",
          },
        },
        groups = {
          all = {
            DiagnosticUnderlineError = { undercurl = true, sp = "#ff5370" },
            DiagnosticUnderlineWarn = { undercurl = true, sp = "#ffcb6b" },
            DiagnosticUnderlineInfo = { undercurl = true, sp = "#82aaff" },
            DiagnosticUnderlineHint = { undercurl = true, sp = "#c3e88d" },
            MiniFilesBorderModified = { fg = "orange" },
            -- SnacksPickerPreview = { bg = "bg1" },
            -- SnacksPickerPreviewTitle = { bg = "bg1" },
            -- SnacksPickerPreviewBorder = { bg = "bg1", fg = "bg1" },
            ["@punctuation.bracket"] = { fg = "#737aa2" },
            -- FloatTitle = { fg = "fg1", bg = "bg0" },
            -- NormalFloat = { bg = "bg0" },
            Pmenu = { bg = "none" },
            PmenuSel = { bg = "#394b70" },
            FloatBorder = { fg = "#292e42" },
            Visual = { bg = "#394b70" },
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
