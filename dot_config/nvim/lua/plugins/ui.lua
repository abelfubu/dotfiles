return {
  "nvim-lua/plenary.nvim",
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      keymaps = {
        ["g?"] = { "actions.show_help", mode = "n" },
        ["<CR>"] = "actions.select",
        ["q"] = { "actions.close", mode = "n" },
        ["<C-p>"] = { "actions.preview", opts = { split = "botright" } },
        ["_"] = { "actions.open_cwd", mode = "n" },
        ["-"] = { "actions.parent", mode = "n" },
        ["gx"] = "actions.open_external",
        ["g."] = { "actions.toggle_hidden", mode = "n" },
      },
      use_default_keymaps = false,
      view_options = {
        show_hidden = true,
      },
      float = {
        preview_split = "right",
      },
      preview = {
        max_width = 0.8,
      },
    },
    keys = {
      -- {
      --   "-",
      --   function()
      --     require("oil").open(
      --       nil,
      --       { preview = { vertical = true, split = "botright" } }
      --     )
      --   end,
      --   desc = "Oil",
      -- },
    },
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    lazy = false,
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
            WinSeparator = { fg = "#292e42" },
            PmenuSel = { bg = "#394b70" },
            FloatBorder = { fg = "#292e42" },
            Visual = { bg = "#394b70" },
            CursorLine = { bg = "#394b70" },
            -- SnacksPickerBorder = { bg = "bg1", fg = "bg1" },
            -- SnacksPicker = { bg = "bg0" },
            -- SnacksPickerFloatTitle = { fg = "fg1", bg = "bg0" },
          },
        },
      }

      vim.cmd "colorscheme github_dark_high_contrast"
    end,
  },
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
