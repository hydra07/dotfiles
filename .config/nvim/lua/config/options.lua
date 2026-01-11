local opt = vim.opt
local sysname = vim.loop.os_uname().sysname
vim.scriptencoding = "utf-8"
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.number = true
opt.title = true
opt.tabstop = 2
opt.showtabline = 2
opt.relativenumber = true
opt.numberwidth = 6
opt.colorcolumn = "1"
opt.shiftwidth = 2
opt.softtabstop = 2
opt.smartindent = true
opt.smarttab = true
opt.expandtab = true
opt.autoindent = true
opt.cindent = true
opt.termguicolors = true
if sysname == "Windows_NT" then
  require("config.window")
elseif sysname == "Darwin" then
  require("config.macos")
else
  require("config.linux")
end
