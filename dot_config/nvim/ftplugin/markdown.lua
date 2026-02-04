vim.api.nvim_create_user_command("Daily", function(args)
  local input = args.args

  vim.lsp.buf.execute_command { command = "jump", arguments = { input } }
end, { desc = "Open daily note", nargs = "*" })
