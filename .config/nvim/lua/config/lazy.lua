local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	spec = {
		{ import = "plugins" },
		{ import = "plugins.completions" },
		{ import = "plugins.editor" },
		{ import = "plugins.ui" },
	},
	defaults = {
		lazy = true,
		version = false,
	},
	checker = { enabled = false },
	change_detection = { enabled = false },
	performance = {
		cache = { enabled = true },
		rtp = {
			disabled_plugins = {
				"gzip",
				"matchit",
				"matchparen",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
				-- Additional disabled plugins for faster startup
				"2html_plugin",
				"getscript",
				"getscriptPlugin",
				"logipat",
				"rrhelper",
				"vimball",
				"vimballPlugin",
			},
		},
	},
	ui = {
		border = "single",
	},
})
