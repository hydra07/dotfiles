local keymaps = require("config.keymaps")

return {
	{
		"stevearc/aerial.nvim",
		cmd = { "AerialToggle", "AerialNavToggle", "AerialInfo" },
		opts = {
			on_attach = function(bufnr)
				keymaps.set_buffer("aerial_prev", "<cmd>AerialPrev<cr>", bufnr)
				keymaps.set_buffer("aerial_next", "<cmd>AerialNext<cr>", bufnr)
			end,
		},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	},
}
