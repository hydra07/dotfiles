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
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = {
			progress = {
				display = {
					render_limit = 3,
					done_ttl = 0.8,
					progress_ttl = math.huge,
					progress_icon = { pattern = "dots", period = 0.8 },
					done_icon = "·",
					icon_style = "Comment",
					group_style = "Comment",
					progress_style = "Comment",
					done_style = "Comment",
				},
			},
			notification = {
				-- Disabled: was adding ~175ms overhead by replacing vim.notify
				override_vim_notify = false,
				filter = vim.log.levels.INFO,
				window = {
					winblend = 8,
					border = "none",
					align = "top",
					relative = "editor",
					x_padding = 1,
					y_padding = 1,
					max_width = 60,
					max_height = 8,
					normal_hl = "Comment",
				},
				view = {
					stack_upwards = false,
					icon_separator = " ",
					group_separator = false,
					line_margin = 0,
					render_message = function(msg, cnt)
						msg = msg:gsub("%s+", " ")
						return cnt == 1 and msg or string.format("%s x%d", msg, cnt)
					end,
				},
			},
		},
	},
}
