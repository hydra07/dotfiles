return {
	-- Deferred: requires telescope's own "telescope.themes" module, only
	-- available once telescope.nvim itself has loaded.
	settings = function()
		return require("telescope.themes").get_dropdown({})
	end,
}
