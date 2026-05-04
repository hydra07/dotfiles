return {
	{
		"nvim-mini/mini.nvim",
		event = { "BufReadPost", "InsertEnter" },
		version = false,
		config = function()
			require("mini.pairs").setup()
			-- (sa: add, sd: delete, sr: replace)
			require("mini.surround").setup()
			require("mini.indentscope").setup({
				symbol = "│",
				options = {
					try_as_border = true,
				},
				draw = {
					delay = 100,
					animation = require("mini.indentscope").gen_animation.none(),
				},
			})
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "help", "lazy", "mason", "notify", "NvimTree", "neo-tree", "terminal", "dashboard" },
				callback = function(args)
					vim.b[args.buf].miniindentscope_disable = true
				end,
			})
			require("mini.comment").setup({
				options = {
					custom_commentstring = function()
						return vim.bo.commentstring
					end,
				},
			})
			require("mini.icons").setup()
		end,
	},
}
