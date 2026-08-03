local icons = require("config.icons")

return {
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "catppuccin/nvim" },
		config = function()
			local C = {
				blue = "#89b4fa",
				mauve = "#cba6f7",
				subtext = "#a6adc8",
			}
			local _cache = { lsp = "", fmt = "" }
			local function refresh_cache()
				local clients, fmts = {}, {}
				for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
					if c.name ~= "copilot" then
						clients[#clients + 1] = c.name
					end
				end
				local ok, conform = pcall(require, "conform")
				if ok then
					for _, f in ipairs(conform.list_formatters(0)) do
						fmts[#fmts + 1] = f.name
					end
				end
				_cache.lsp = #clients > 0 and (icons.lsp_client .. table.concat(clients, "·")) or ""
				_cache.fmt = #fmts > 0 and (icons.formatter .. table.concat(fmts, "·")) or ""
			end
			local function tools_segment()
				local parts = {}
				if _cache.fmt ~= "" then
					parts[#parts + 1] = _cache.fmt
				end
				if _cache.lsp ~= "" then
					parts[#parts + 1] = _cache.lsp
				end
				return table.concat(parts, " │ ")
			end
			local function terminal_status()
				local ok, toggleterm = pcall(require, "toggleterm.terminal")
				if not ok then
					return ""
				end
				local terms = toggleterm.get_all()
				if #terms == 0 then
					return ""
				end
				local active_buf = vim.api.nvim_get_current_buf()
				local parts = {}
				for _, term in ipairs(terms) do
					local is_current = (term.bufnr == active_buf)
					local is_open = term:is_open()
					local state = ""
					if is_current then
						state = icons.terminal.current
					elseif is_open then
						state = icons.terminal.open
					else
						state = icons.terminal.hidden
					end
					table.insert(parts, string.format("%d%s", term.id, state))
				end
				return "  " .. table.concat(parts, "·")
			end
			local function enc_display()
				local enc = vim.bo.fileencoding
				return (enc ~= "" and enc ~= "utf-8") and enc or ""
			end

			vim.api.nvim_create_autocmd({ "BufEnter", "LspAttach", "LspDetach" }, { callback = refresh_cache })
			vim.api.nvim_create_autocmd({ "TermOpen", "TermClose", "BufEnter", "WinEnter" }, {
				callback = function()
					pcall(function()
						require("lualine").refresh()
					end)
				end,
			})

			local ok, lualine = pcall(require, "lualine")
			if not ok then
				return
			end
			lualine.setup({
				options = {
					theme = "auto",
					-- Hard/sharp powerline glyphs U+E0B0-U+E0B3 (byte-escaped: PUA codepoints
					-- don't survive as literal source characters reliably) — the solid/thin
					-- arrow pair, NOT the rounded U+E0B4/U+E0B6 variants.
					section_separators = { left = "\238\130\176", right = "\238\130\178" },
					component_separators = { left = "\238\130\177", right = "\238\130\179" },
					globalstatus = true,
					refresh = { statusline = 500 },
					always_divide_middle = true,
					disabled_filetypes = { statusline = { "dashboard", "alpha", "neo-tree", "lazy", "mason", "toggleterm" } },
				},
				sections = {
					lualine_a = {
						{ "mode" },
					},
					lualine_b = {
						{ "branch", icon = icons.git_branch },
						"diff",
						{ "diagnostics", symbols = icons.diagnostics },
					},
					lualine_c = {
						{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
						{
							"filename",
							path = 1,
							symbols = { modified = " ●", readonly = " 󰌾", unnamed = " [No Name]" },
						},
					},
					lualine_x = {
						{
							terminal_status,
							color = { fg = C.mauve, gui = "bold" },
							cond = function()
								return terminal_status() ~= ""
							end,
						},
						{
							tools_segment,
							color = { fg = C.blue, gui = "bold" },
							cond = function()
								return _cache.lsp ~= "" or _cache.fmt ~= ""
							end,
						},
						{
							enc_display,
							color = { fg = C.subtext },
							cond = function()
								return enc_display() ~= ""
							end,
						},
					},
					lualine_y = { "progress" },
					lualine_z = {
						{ "location" },
					},
				},
				extensions = { "neo-tree", "lazy", "mason", "toggleterm" },
			})
		end,
	},
}
