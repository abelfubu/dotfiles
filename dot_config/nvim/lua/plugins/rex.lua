if
  vim.g.loaded_rex_navigator
  or not vim.env.REX_SESSION
  or vim.env.REX_SESSION == ""
then
  return {}
end
vim.g.loaded_rex_navigator = true

local function navigate(wincmd, direction)
  local win = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() == win then
    vim.system {
      vim.env.REX_BIN_PATH or "rex",
      "focus",
      direction,
      "-s",
      vim.env.REX_SESSION,
    }
  end
end

-- Mapped on VimEnter so these win over vim-tmux-navigator and other plugins' defaults.
local function map()
  for lhs, nav in pairs {
    ["<C-h>"] = { "h", "left" },
    ["<C-j>"] = { "j", "down" },
    ["<C-k>"] = { "k", "up" },
    ["<C-l>"] = { "l", "right" },
  } do
    vim.keymap.set("n", lhs, function()
      navigate(nav[1], nav[2])
    end, { silent = true, desc = "Navigate " .. nav[2] .. " (Neovim/Rex)" })
  end
end

-- Resize splits: Ctrl+Shift+{h,j,k,l} (requires kitty keyboard protocol / GUI).
local function map_resize()
  local deltas = { h = "<", j = "-", k = "+", l = ">" }
  for key, delta in pairs(deltas) do
    vim.keymap.set("n", "<C-S-" .. key .. ">", function()
      vim.cmd { cmd = "wincmd", args = { delta }, count = vim.v.count1 }
    end, { silent = true, desc = "Resize pane " .. key })
  end
end

if vim.v.vim_did_enter == 1 then
  map_resize()
else
  vim.api.nvim_create_autocmd(
    "VimEnter",
    { once = true, callback = map_resize }
  )
end

if vim.v.vim_did_enter == 1 then
  map()
else
  vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = map })
end

return { {} }
