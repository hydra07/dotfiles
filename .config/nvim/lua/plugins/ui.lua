return {
	{
		"folke/tokyonight.nvim",
		opts = {
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				transparent_background = true,
				term_colors = true,
				custom_highlights = function(colors)
					return {
						LineNr = { fg = colors.overlay1 },
						CursorLineNr = { fg = colors.lavender, bold = true },
						-- VertSplit = { fg = colors.surface1 },
					}
				end,
				integrations = {
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
					trouble = true,
				},
				compile = { enabled = true },
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},
}
