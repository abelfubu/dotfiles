return {
  "nvim-lua/plenary.nvim",
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>bo",
        "<Cmd>BufferLineCloseOthers<CR>",
        desc = "Close All Other Buffers",
      },
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
      {
        "<leader>bP",
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
    dir = "~/dev/moksha.nvim",
    priority = 1000,
    config = function()
      require("moksha").setup { palette = "merino_dark" }
      vim.cmd "colorscheme moksha"
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
