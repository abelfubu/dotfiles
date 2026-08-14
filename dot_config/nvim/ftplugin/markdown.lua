vim.api.nvim_create_user_command("Daily", function(args)
  vim.lsp.buf.execute_command {
    command = "jump",
    arguments = { input = args.args },
  }
end, { desc = "Open daily note", nargs = "*" })
