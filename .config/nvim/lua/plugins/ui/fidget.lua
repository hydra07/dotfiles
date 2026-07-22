return {
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = function()
			return {
				progress = {
					-- 20Hz: smooth enough that any terminal can keep up rendering (higher -> dropped frames -> stutter).
					poll_rate = 20,
					display = {
						render_limit = 4,
						done_ttl = 2,
						progress_ttl = math.huge,
						progress_icon = { pattern = "dots", period = 1 },
						done_icon = "",
						icon_style = "CmpItemKindEvent",
						group_style = "Title",
						progress_style = "Comment",
						done_style = "DiagnosticOk",
					},
				},
				notification = {
					-- Disabled: was adding ~175ms overhead by replacing vim.notify
					override_vim_notify = false,
					filter = vim.log.levels.INFO,
					poll_rate = 20,
					window = {
						winblend = 0,
						border = "rounded",
						align = "top", -- top-right (fidget always anchors to the right edge)
						relative = "editor",
						x_padding = 2,
						y_padding = 1,
						max_width = 72,
						max_height = 10,
					},
					view = {
						stack_upwards = false, -- anchored at top: newest goes below the older ones
						icon_separator = "  ",
						group_separator = "──────",
						group_separator_hl = "NonText",
						render_message = function(msg, cnt)
							msg = msg:gsub("%s+", " ")
							return cnt == 1 and msg or string.format("%s ×%d", msg, cnt)
						end,
					},
					configs = {
						default = vim.tbl_extend("force", require("fidget.notification").default_config, {
							icon = "",
							icon_style = "DiagnosticInfo",
							name_style = "Title",
							annote_style = "Comment",
							debug_style = "Comment",
							info_style = "DiagnosticInfo",
							warn_style = "DiagnosticWarn",
							error_style = "DiagnosticError",
							priority = 30,
						}),
					},
				},
			}
		end,
		config = function(_, opts)
			require("fidget").setup(opts)

			-- ── Time each LSP server's load and report via fidget when done ──────
			local starts = {} -- key = "client_id:token" -> start hrtime
			local function fmt(ms)
				if ms < 1000 then
					return string.format("%.0fms", ms)
				end
				return string.format("%.2fs", ms / 1000)
			end

			vim.api.nvim_create_autocmd("LspProgress", {
				group = vim.api.nvim_create_augroup("UserLspLoadTime", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if not client then
						return
					end
					local v = args.data.params and args.data.params.value
					if not v or not v.kind then
						return
					end
					local key = args.data.client_id .. ":" .. tostring(args.data.params.token)
					if v.kind == "begin" then
						starts[key] = vim.uv.hrtime()
					elseif v.kind == "end" then
						local t0 = starts[key]
						starts[key] = nil
						if t0 then
							local ms = (vim.uv.hrtime() - t0) / 1e6
							require("fidget").notify(client.name .. " ready", vim.log.levels.INFO, {
								annote = "· " .. fmt(ms),
								-- stable key per client -> updates the same line instead of stacking
								key = "lsp-load-" .. client.name,
								ttl = 3,
							})
						end
					end
				end,
			})
		end,
	},
}
