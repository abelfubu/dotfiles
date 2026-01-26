local M = {}

M.harpoon_picker = function()
  local harpoon = require "harpoon"

  require("snacks").picker.pick {
    finder = function()
      local items = {}
      local list = harpoon:list()

      local max = list:length() or #list.items

      for i = 1, max do
        local item = list.items[i]

        if item and item.value then
          table.insert(items, {
            idx = i,
            text = item.value,
            file = item.value,
            original = item,
          })
        else
          table.insert(items, {
            idx = i,
            text = "",
            file = "",
            empty = true,
          })
        end
      end

      return items
    end,
    title = "Harpoon",
    layout = "select",
    on_show = require("utils.nvim.helpers").stop_insert,
    format = function(item, picker)
      if item.empty then
        return { { string.format("%d. [empty]", item.idx) } }
      end

      local chunks = require("snacks.picker.format").file(item, picker)

      chunks[1][1] = string.format("%d. %s", item.idx, chunks[1][1])

      return chunks
    end,
    actions = {
      delete_mark = function(picker, item)
        if not item then
          return
        end

        local list = harpoon:list()
        list:remove(item.original)

        vim.notify(
          "Removed mark: " .. item.file,
          vim.log.levels.INFO,
          { title = "Harpoon" }
        )

        picker:refresh()
      end,
      move_up = function(picker, item)
        if not item or item.idx <= 1 then
          return
        end
        local list = harpoon:list()
        local previous = list:get(item.idx - 1)

        list:replace_at(item.idx - 1, item.original)
        list:replace_at(item.idx, previous)

        picker:refresh()
        picker.list:move(-1)
      end,
      move_down = function(picker, item)
        if not item or item.idx >= #harpoon:list().items then
          return
        end
        local list = harpoon:list()

        local next = list:get(item.idx + 1)
        list:replace_at(item.idx + 1, item.original)

        list:replace_at(item.idx, next)
        picker:refresh()

        picker.list:move(1)
      end,
      clean = function(picker)
        harpoon:list():clear()
        picker:refresh()
      end,
    },
    win = {
      input = {
        keys = {
          ["D"] = { "delete_mark", mode = "n" },
          ["K"] = { "move_up", mode = "n" },
          ["J"] = { "move_down", mode = "n" },
          ["X"] = { "clean", mode = "n" },
        },
      },
    },
    confirm = function(picker, item)
      picker:close()
      if item then
        harpoon:list():select(item.idx)
      end
    end,
  }
end

return M
