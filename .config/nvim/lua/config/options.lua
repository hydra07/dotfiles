local opt = vim.opt
local sysname = vim.uv.os_uname().sysname
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

-- Persistence & Performance
opt.undofile = true
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.synmaxcol = 240

-- Disable unused providers for faster startup
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0


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

local platform_module = ({
	Windows_NT = "config.window",
	Darwin = "config.macos",
})[sysname] or "config.linux"

local ok, err = pcall(require, platform_module)
if not ok then
	vim.notify(("Failed to load %s: %s"):format(platform_module, err), vim.log.levels.ERROR)
end

