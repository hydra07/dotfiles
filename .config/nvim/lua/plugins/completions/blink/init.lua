return {
	{
		"saghen/blink.cmp",
		version = "*",
		event = "InsertEnter",
		dependencies = {
			"rafamadriz/friendly-snippets",
			"xzbdmw/colorful-menu.nvim",
		},
		opts = function()
			local function accept_index(index)
				return function(cmp)
					return cmp.accept({ index = index })
				end
			end

			local icons = require("plugins.completions.blink.icons")
			local kind_icons = icons.kind_icons
			local source_labels = icons.source_labels

			return {
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
					["<A-1>"] = { accept_index(2), "fallback" },
					["<A-2>"] = { accept_index(3), "fallback" },
					["<A-3>"] = { accept_index(4), "fallback" },
					["<A-4>"] = { accept_index(5), "fallback" },
					["<A-5>"] = { accept_index(6), "fallback" },
					["<A-6>"] = { accept_index(7), "fallback" },
					["<A-7>"] = { accept_index(8), "fallback" },
					["<A-8>"] = { accept_index(9), "fallback" },
					["<A-9>"] = { accept_index(10), "fallback" },
				},
				appearance = {
					nerd_font_variant = "mono",
					kind_icons = kind_icons,
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
						-- Cap the list -> less sorting/rendering work when ts7 returns thousands of items.
						max_items = 200,
					},
					ghost_text = { enabled = true },
					menu = {
						auto_show = function(ctx)
							return ctx.mode ~= "cmdline"
						end,
						border = "single",
						max_height = 12,
						scrollbar = false,
						draw = {
							-- Layout: [shortcut] [icon] [label ~~~~~~~~~~ kind  source]
							columns = {
								{ "trigger" },
								{ "kind_icon" },
								{ "label", gap = 1 },
								{ "kind", gap = 1 },
								{ "source_name" },
							},
							components = {
								trigger = {
									width = { max = 4 },
									text = function(ctx)
										if ctx.idx == 1 then
											return "Tab"
										end
										if ctx.idx <= 10 then
											return "A-" .. tostring(ctx.idx - 1)
										end
										return ""
									end,
									highlight = "BlinkCmpGhostText",
								},
								kind_icon = {
									text = function(ctx)
										local icon = kind_icons[ctx.kind] or ctx.kind_icon or ""
										return icon .. " "
									end,
									highlight = function(ctx)
										local hl = ctx.kind_hl
										if ctx.kind == "Color" then
											return hl
										end
										return "BlinkCmpKind" .. ctx.kind
									end,
								},
								label = {
									text = function(ctx)
										return require("colorful-menu").blink_components_text(ctx)
									end,
									highlight = function(ctx)
										return require("colorful-menu").blink_components_highlight(ctx)
									end,
								},
								kind = {
									width = { max = 14 },
									text = function(ctx)
										return ctx.kind or ""
									end,
									highlight = "BlinkCmpKind",
								},
								source_name = {
									width = { max = 6 },
									text = function(ctx)
										return source_labels[ctx.source_id] or ""
									end,
									highlight = "Comment",
								},
							},
						},
					},
					documentation = {
						window = {
							border = "single",
							max_width = 60,
							max_height = 20,
						},
						auto_show = true,
						auto_show_delay_ms = 150,
					},
				},
				fuzzy = {
					implementation = "prefer_rust_with_warning",
				},
				sources = {
					default = { "lsp", "path", "snippets", "buffer" },
					providers = {
						lsp = {
							score_offset = 10,
						},
						buffer = {
							-- Only suggest from buffer after typing >= 4 chars, and cap the
							-- count without blocking the menu -> less scanning per keystroke on big files.
							min_keyword_length = 4,
							max_items = 6,
							score_offset = -3,
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
						list = { selection = { preselect = true, auto_insert = false } },
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
			}
		end,
		-- When blink.cmp loads, update all running LSP clients with enhanced capabilities
		config = function(_, opts)
			local blink = require("blink.cmp")
			blink.setup(opts)

			-- Dynamically update capabilities for already-running LSP clients
			local capabilities = blink.get_lsp_capabilities()
			for _, client in ipairs(vim.lsp.get_clients()) do
				client.capabilities = vim.tbl_deep_extend("force", client.capabilities, capabilities)
			end
		end,
	},
}
