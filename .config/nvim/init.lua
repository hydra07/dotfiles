if vim.loader then
	vim.loader.enable()
end
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function safe_require(mod)
	local ok, err = pcall(require, mod)
	if not ok then
		vim.notify(("Failed to load %s: %s"):format(mod, err), vim.log.levels.ERROR)
	end
end

safe_require("config.options")
safe_require("config.autocmds")
safe_require("config.keymaps")
safe_require("config.lazy")

if vim.g.neovide then
	safe_require("config.neovide")
end
