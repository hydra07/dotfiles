local opt = vim.opt
local sysname = vim.loop.os_uname().sysname
vim.scriptencoding = "utf-8"
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

-- UI
opt.number = true
opt.relativenumber = true
opt.numberwidth = 4
opt.signcolumn = "yes"
opt.cursorline = true
opt.colorcolumn = ""
opt.updatetime = 1000
opt.timeoutlen = 300

-- Indent
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

opt.wrap = false
-- opt.breakindent = true
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.fillchars = {
	eob = " ",
	fold = " ",
	vert = "|",
	-- View
}
opt.showtabline = 0
opt.smarttab = true
opt.title = true
-- opt.cindent = true
opt.termguicolors = true

if sysname == "Windows_NT" then
	require("config.window")
elseif sysname == "Darwin" then
	require("config.macos")
else
	require("config.linux")
end
