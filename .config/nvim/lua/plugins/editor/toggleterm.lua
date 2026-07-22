local keymaps = require("config.keymaps")

return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = { "ToggleTerm", "TermSelect", "ToggleTermToggleAll" },
		keys = (function()
			local keys = {
				keymaps.bind("toggle_terminal", "<cmd>ToggleTerm<cr>"),
				keymaps.bind("terminal_horizontal", "<cmd>ToggleTerm direction=horizontal<cr>"),
				keymaps.bind("terminal_float", "<cmd>ToggleTerm direction=float<cr>"),
				keymaps.bind("terminal_vertical", "<cmd>ToggleTerm direction=vertical<cr>"),
				keymaps.bind("terminal_select", "<cmd>TermSelect<cr>"),
				keymaps.bind("terminal_toggle_all", "<cmd>ToggleTermToggleAll<cr>"),
			}
			for i = 1, 9 do
				keys[#keys + 1] = keymaps.bind("terminal_" .. i, string.format("<cmd>%dToggleTerm<cr>", i))
			end
			return keys
		end)(),
		config = function()
			require("toggleterm").setup({
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
				end,
				open_mapping = [[<C-\>]],
				hide_numbers = true,
				shade_terminals = false,
				start_in_insert = true,
				insert_mappings = true,
				persist_size = true,
				direction = "horizontal",
				close_on_exit = true,
				shell = vim.o.shell,
				float_opts = {
					border = "rounded",
					winblend = 10,
				},
			})
			-- Window-nav <C-h/j/k/l> in terminal mode is already global (config/keymaps.lua);
			-- only the exit-to-normal-mode maps are genuinely terminal-buffer-specific.
			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "term://*",
				callback = function()
					local bufnr = vim.api.nvim_get_current_buf()
					keymaps.set_buffer("terminal_exit_escape", [[<C-\><C-n>]], bufnr)
					keymaps.set_buffer("terminal_exit_jk", [[<C-\><C-n>]], bufnr)
				end,
			})
			vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
				pattern = "term://*",
				callback = function()
					vim.cmd("startinsert")
				end,
			})
		end,
	},
}
