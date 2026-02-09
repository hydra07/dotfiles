return {
	{
		"saghen/blink.cmp",
		version = "*",
		event = "InsertEnter",
		dependencies = {
			"rafamadriz/friendly-snippets",
			"xzbdmw/colorful-menu.nvim",
			"fang2hou/blink-copilot",
		},
		opts = {
			keymap = {
				preset = "none",
				["<Tab>"] = {
					function(cmp)
						if cmp.is_menu_visible() or cmp.is_ghost_text_visible() then
							return cmp.select_and_accept()
						end
					end,
					"snippet_forward",
					"fallback",
				},
				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },
				["<CR>"] = { "fallback" },
				["<S-Tab>"] = { "snippet_backward", "fallback" },
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
			},
			completion = {
				trigger = {
					show_on_x_blocked_trigger_characters = { "'", '"', "(" },
				},
				list = {
					selection = {
						preselect = true,
						auto_insert = false,
					},
				},
				ghost_text = { enabled = true },
				menu = {
					auto_show = function(ctx)
						return ctx.mode ~= "cmdline"
					end,
					border = "single",
					draw = {
						columns = { { "kind_icon" }, { "label", gap = 1 } },
						components = {
							label = {
								text = function(ctx)
									return require("colorful-menu").blink_components_text(ctx)
								end,
								highlight = function(ctx)
									return require("colorful-menu").blink_components_highlight(ctx)
								end,
							},
						},
					},
				},
				documentation = {
					window = { border = "single" },
					auto_show = true,
					auto_show_delay_ms = 200,
				},
			},
			fuzzy = {
				implementation = "prefer_rust_with_warning",
			},
			sources = {
				default = { "copilot", "lsp", "path", "snippets", "buffer" },
				providers = {
					copilot = {
						name = "copilot",
						module = "blink-copilot",
						score_offset = 0,
						async = true,
						min_keyword_length = 0,
					},
					lsp = {
						score_offset = 10,
					},
				},
			},
			cmdline = {
				enabled = true,
				keymap = {
					preset = "none",
					["<Tab>"] = { "select_next", "fallback" },
					["<S-Tab>"] = { "select_prev", "fallback" },
					["<CR>"] = { "accept", "fallback" },
					["<C-e>"] = { "hide", "fallback" },
				},
				completion = {
					menu = {
						auto_show = true,
						draw = { columns = { { "label" } } },
					},
					list = { selection = { preselect = true, auto_insert = true } },
					ghost_text = { enabled = false },
				},
				sources = function()
					local type = vim.fn.getcmdtype()
					if type == "/" or type == "?" then
						return { "buffer" }
					end
					if type == ":" then
						return { "cmdline" }
					end
					return {}
				end,
			},
		},
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		keys = {
			{
				"<leader>ct",
				function()
					local client = require("copilot.client")
					if client.is_disabled() then
						vim.cmd("Copilot enable")
						vim.notify("Copilot Enabled", vim.log.levels.INFO, { title = "Copilot" })
					else
						vim.cmd("Copilot disable")
						vim.notify("Copilot Disabled", vim.log.levels.WARN, { title = "Copilot" })
					end
				end,
				desc = "Copilot: Toggle On/Off",
			},
		},
		opts = {
			suggestion = { enabled = false },
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				help = true,
			},
		},
	},
}
