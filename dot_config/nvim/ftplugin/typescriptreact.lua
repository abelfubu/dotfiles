---@param types string[] Will return the first node that matches one of these types
---@param node TSNode|nil
---@return TSNode|nil
local function find_node_ancestor(types, node)
  if not node then
    return nil
  end

  if vim.tbl_contains(types, node:type()) then
    return node
  end

  local parent = node:parent()

  return find_node_ancestor(types, parent)
end

---When typing "await" add "async" to the function declaration if the function
---isn't async already.
local function add_async()
  -- This function should be executed when the user types "t" in insert mode,
  -- but "t" is not inserted because it's the trigger.
  vim.api.nvim_feedkeys("t", "n", true)

  local buffer = vim.fn.bufnr()

  local text_before_cursor =
    vim.fn.getline("."):sub(vim.fn.col "." - 4, vim.fn.col "." - 1)
  if text_before_cursor ~= "awai" then
    return
  end

  -- ignore_injections = false makes this snippet work in filetypes where JS is injected
  -- into other languages
  local current_node = vim.treesitter.get_node { ignore_injections = false }
  local function_node = find_node_ancestor({
    "arrow_function",
    "function_declaration",
    "function",
    "method_definition",
  }, current_node)
  if not function_node then
    return
  end

  local function_text = vim.treesitter.get_node_text(function_node, 0)
  if vim.startswith(function_text, "async") then
    return
  end

  if vim.startswith(function_text, "public async") then
    return
  end
  if vim.startswith(function_text, "private async") then
    return
  end
  if vim.startswith(function_text, "protected async") then
    return
  end

  local start_row, start_col = function_node:start()

  if vim.startswith(function_text, "public") then
    start_col = start_col + 7
  end
  if vim.startswith(function_text, "private") then
    start_col = start_col + 8
  end
  if vim.startswith(function_text, "protected") then
    start_col = start_col + 10
  end

  vim.api.nvim_buf_set_text(
    buffer,
    start_row,
    start_col,
    start_row,
    start_col,
    { "async " }
  )
end

local function add_tilde_string()
  vim.api.nvim_feedkeys("{}", "n", true)
  -- Move the cursor back inside the braces
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("<Left>", true, false, true),
    "n",
    true
  )

  local text_before_cursor =
    vim.fn.getline("."):sub(vim.fn.col "." - 1, vim.fn.col "." - 1)
  if text_before_cursor ~= "$" then
    return
  end

  local current_node = vim.treesitter.get_node { ignore_injections = false }
  if current_node:type() ~= "string" then
    return
  end

  local string_text = vim.treesitter.get_node_text(current_node, 0)
  print(string_text)
  if vim.startswith(string_text, "`") then
    return
  end

  local start_row, start_col = current_node:start()
  local end_row, end_col = current_node:end_()

  vim.api.nvim_buf_set_text(
    0,
    start_row,
    start_col,
    start_row,
    start_col + 1,
    { "`" }
  )
  vim.api.nvim_buf_set_text(0, end_row, end_col - 1, end_row, end_col, { "`" })
end

vim.keymap.set(
  "v",
  "<leader>cl",
  "yoconsole.log('[<Esc>pa]', <Esc>pa)<Esc>",
  { buffer = true }
)
vim.keymap.set(
  "n",
  "<leader>cl",
  "viwyoconsole.log('[<Esc>pa]', <Esc>pa)<Esc>",
  { buffer = true }
)
vim.keymap.set("i", "t", add_async, { buffer = true })
vim.keymap.set("i", "{", add_tilde_string, { buffer = true })
