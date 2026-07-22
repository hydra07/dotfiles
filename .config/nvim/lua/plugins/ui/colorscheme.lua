return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			flavour = "mocha",
			transparent_background = true,
			term_colors = true,
			custom_highlights = function(colors)
				return {
					LineNr = { fg = colors.overlay1 },
					CursorLineNr = { fg = colors.lavender, bold = true },
				}
			end,
			integrations = {
				lazy = true,
				blink_cmp = true,
				mini = { enabled = true },
				mason = true,
				telescope = {
					enabled = true,
					styles = { "nvchad" },
				},
				lualine = true,
				neotree = true,
				dashboard = true,
				native_lsp = {
					enabled = true,
					underlines = {
						errors = { "undercurl" },
						hints = { "undercurl" },
						warnings = { "undercurl" },
						information = { "undercurl" },
					},
				},
				treesitter = true,
				which_key = true,
			},
			compile = { enabled = true },
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
