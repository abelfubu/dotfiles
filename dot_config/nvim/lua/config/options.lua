vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.termguicolors = true
vim.o.wrap = false

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.ignorecase = true
vim.o.swapfile = false
vim.g.mapleader = " "
vim.o.winborder = "rounded"
vim.o.clipboard = "unnamedplus"
vim.opt.cmdheight = 1
vim.opt.laststatus = 3

vim.g.have_nerd_font = true

if vim.fn.has "win32" == 1 or vim.fn.has "win64" == 1 then
  vim.o.shell = "pwsh"
  vim.o.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
end
