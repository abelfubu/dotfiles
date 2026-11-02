return {
  "nvim-lua/plenary.nvim",
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    after = "catppuccin",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      {
        "<leader>bo",
        "<Cmd>BufferLineGroupClose ungrouped<CR>",
        desc = "Delete Non-Pinned Buffers",
      },
      {
        "<leader>br",
        "<Cmd>BufferLineCloseRight<CR>",
        desc = "Delete Buffers to the Right",
      },
      {
        "<leader>bl",
        "<Cmd>BufferLineCloseLeft<CR>",
        desc = "Delete Buffers to the Left",
      },
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
      { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
      { "<leader>bb", "<cmd>BufferLinePick<cr>", desc = "Pick Buffer" },
    },
    config = function()
      local bufferline = require "bufferline"
      bufferline.setup {
        options = {
          style_preset = bufferline.style_preset.no_italic,
        },
        -- highlights = require("catppuccin.special.bufferline").get_theme(),
        highlights = {
          -- buffer_selected = {
          --   fg = "white",
          -- },
        },
      }
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        section_separators = { left = "", right = "" },
        component_separators = { left = "", right = "" },
      },
    },
  },
  {
    "afonsofrancof/OSC11.nvim",
    lazy = false,
    opts = {
      on_dark = function()
        vim.opt.background = "dark"
        vim.cmd.colorscheme "github_dark_default"
      end,
      on_light = function()
        vim.opt.background = "light"
        vim.cmd.colorscheme "github_light_default"
      end,
    },
  },
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup {
        options = {
          transparent = true,
        },
        groups = {
          all = {
            DiffviewFilePanelInsertions = { fg = "palette.green", bg = "NONE" },
            DiffviewFilePanelDeletions = { fg = "palette.red", bg = "NONE" },
            DiffviewStatusModified = { fg = "palette.blue", bg = "NONE" },
            DiffviewStatusAdded = { fg = "palette.green", bg = "NONE" },
            DiffviewStatusDeleted = { fg = "palette.red", bg = "NONE" },
            TabLineFill = { bg = "NONE" },
            Pmenu = { bg = "NONE" },
            PmenuSel = { bg = "#2F81F7", fg = "#FFFFFF" },
            Visual = { bg = "#2F81F7", fg = "#FFFFFF" },
            MiniFilesCursorLine = { bg = "#58A6FF", fg = "#FFFFFF" },
          },
        },
      }

      vim.cmd "colorscheme github_dark_default"
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("tokyonight").setup {
        transparent = true,
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
          functions = { italic = false },
          variables = { italic = false },
          sidebars = "transparent",
          floats = "transparent",
        },
        on_highlights = function(hl, c)
          hl.DiffviewFilePanelInsertions = { fg = c.green, bg = "NONE" }
          hl.DiffviewFilePanelDeletions = { fg = c.red, bg = "NONE" }
          hl.DiffviewStatusModified = { fg = c.blue, bg = "NONE" }
          hl.DiffviewStatusAdded = { fg = c.green, bg = "NONE" }
          hl.DiffviewStatusDeleted = { fg = c.red, bg = "NONE" }
          hl.FloatBorder = { fg = c.terminal_black, bg = "NONE" }
        end,
      }
      -- vim.cmd.colorscheme "tokyonight-night"
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup {
        flavour = "auto",
        background = {
          light = "latte",
          dark = "mocha",
        },
        float = {
          transparent = true,
          solid = false,
        },
        transparent_background = true,
        no_italic = true,
        auto_integrations = true,
        lsp_styles = {
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
      }

      -- vim.cmd.colorscheme "catppuccin-mocha"
    end,
  },
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
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    lazy = false,
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
