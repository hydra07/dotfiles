return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		keys = {
			{ ";f", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{ ";r", "<cmd>Telescope live_grep<cr>", desc = "Live Grep (Search Text)" },
			{ ";b", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
			{ ";;", "<cmd>Telescope resume<cr>", desc = "Resume last search" },
			{ ";e", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", desc = "File Browser (Root)" },
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local fb_actions = telescope.extensions.file_browser.actions
			telescope.setup({
				defaults = {
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
						"--glob=!.git/*",
						"--glob=!**/build/*",
						"--glob=!**/dist/*",
						-- for node
						"--glob=!**/node_modules/*",
						"--glob=!**/.next/*",
						"--glob=!**/package-lock.json",
						"--glob=!**/yarn.lock",
						"--glob=!**/pnpm.lock",
						"--glob=!**/bun.lock",
					},
					find_command = {
						"fd",
						"--type",
						"f",
						"--strip-cwd-prefix",
						"--hidden",
						"--exclude",
						".git",
						"--exclude",
						"node_modules",
						"--exclude",
						"dist",
						"--exclude",
						"build",
						"--exclude",
						".next",
					},
					sorting_strategy = "ascending",
					layout_config = {
						horizontal = { prompt_position = "top", preview_width = 0.55 },
					},
					mappings = {
						i = {
							["<C-j>"] = actions.move_selection_next, -- Đồng bộ với Blink.cmp
							["<C-k>"] = actions.move_selection_previous,
							["<C-n>"] = actions.cycle_history_next,
							["<C-p>"] = actions.cycle_history_prev,
						},
					},
				},
				extensions = {
					file_browser = {
						-- theme = "ivy",
						hijack_netrw = true,
						hidden = true,
						mappings = {
							["i"] = {
								["<C-a>"] = fb_actions.create, -- add
								["<C-r>"] = fb_actions.rename, -- rename
								["<C-d>"] = fb_actions.remove, -- delete
								["<C-m>"] = fb_actions.move, -- move
								["<C-h>"] = fb_actions.toggle_hidden, -- toggle hidden
							},
						},
					},
				},
			})
			-- Active extensions
			telescope.load_extension("file_browser")
			telescope.load_extension("fzf")
		end,
	},
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = { "ToggleTerm", "TermSelect", "ToggleTermToggleAll" },

		keys = {
			{ [[<C-\>]], "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" },
			{ "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal Horizontal" },
		},
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
				direction = "horizontal", -- Mặc định nhét xuống dưới
				close_on_exit = true,
				shell = vim.o.shell,
				float_opts = {
					border = "single",
					winblend = 0,
				},
			})

			-- Hàm để mở Terminal với ID cụ thể
			-- Ví dụ: 1<C-\> mở terminal 1, 2<C-\> mở terminal 2
			function _G.set_terminal_keymaps()
				local opts = { buffer = 0 }
				vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
				vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
				vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
				vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
			end

			vim.api.nvim_create_autocmd("TermOpen", {
				pattern = "term://*",
				callback = function()
					_G.set_terminal_keymaps()
				end,
			})
			vim.keymap.set(
				"n",
				"<leader>th",
				"<cmd>ToggleTerm direction=horizontal<cr>",
				{ desc = "Terminal Horizontal" }
			)
			vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal Float" })
			vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal Vertical" })
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		lazy = false,
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer NeoTree (Root Dir)" },
		},
		opts = {
			filesystem = {
				filtered_items = {
					visible = true, -- show hidden files
					hide_dotfiles = false,
				},
				follow_current_file = { enabled = true }, -- show current file in tree
				use_libuv_file_watcher = true, -- auto refresh
			},
			window = {
				width = 30,
				mappings = {},
			},
		},
	},
	{
		"akinsho/bufferline.nvim",
		optional = true,
		opts = function(_, opts)
			if (vim.g.colors_name or ""):find("catppuccin") then
				opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
			end
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = {
			"catppuccin/nvim",
			"nvim-tree/nvim-web-devicons",
			"AndreM222/copilot-lualine", -- Thêm dependency này
		},
		opts = function()
			local function get_formatter()
				local ok, conform = pcall(require, "conform")
				if not ok then
					return ""
				end
				local formatters = conform.list_formatters(0)
				if #formatters == 0 then
					return ""
				end
				return formatters[1].name
			end

			local function get_lsp_client()
				local clients = vim.lsp.get_clients({ bufnr = 0 })
				if #clients == 0 then
					return ""
				end
				local formatter_name = get_formatter()
				local client_names = {}
				for _, client in ipairs(clients) do
					if client.name ~= formatter_name and client.name ~= "copilot" then
						table.insert(client_names, client.name)
					end
				end
				if #client_names == 0 then
					return ""
				end
				return " " .. table.concat(client_names, ", ")
			end

			local function inlay_status()
				if vim.lsp.inlay_hint and vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }) then
					return "󰄲 Hints"
				end
				return ""
			end

			return {
				options = {
					theme = catppuccin,
					component_separators = { left = "│", right = "│" },
					section_separators = { left = "", right = "" },
					globalstatus = true,
					refresh = { statusline = 1000 }, -- Giảm refresh xuống 1s để icon Copilot nhạy hơn
					disabled_filetypes = { statusline = { "dashboard", "alpha", "neo-tree" } },
				},
				sections = {
					lualine_a = { { "mode", right_padding = 2 } },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = {
						{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
						{ "filename", path = 1 },
					},
					lualine_x = {
						{
							"copilot",
							symbols = {
								status = {
									icons = {
										enabled = " ",
										disabled = " ",
										warning = " ",
										unknown = " ",
									},
									hl = {
										enabled = "#50fa7b",
										disabled = "#ff5555",
										warning = "#ffb86c",
										unknown = "#ff5555",
									},
								},
							},
							show_colors = true,
							show_loading = true,
						},
						{ inlay_status, color = { fg = "#fab387" } },
						{
							function()
								local f = get_formatter()
								return f ~= "" and ("󰉼 " .. f) or ""
							end,
							color = { fg = "#a6e3a1" },
							cond = function()
								return get_formatter() ~= ""
							end,
						},
						{
							get_lsp_client,
							color = { fg = "#89b4fa", gui = "bold" },
							cond = function()
								return #vim.lsp.get_clients({ bufnr = 0 }) > 0
							end,
						},
						{ "encoding" },
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				extensions = { "neo-tree", "lazy", "mason" },
			}
		end,
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			labels = "asdfghjklqwertyuiopzxcvbnm",
			label = {
				after = true,
				highlight = {
					backdrop = true,
				},
			},
			search = {
				enabled = true,
				multi_window = false,
			},
			modes = {
				char = {
					enabled = true,
					keys = { "f", "F", "t", "T" },
					jump_labels = true,
				},
			},
			prompts = {
				enabled = true,
				-- prefix = { { "⚡", "FlashPromptIcon" } },
			},
		},
		keys = {
			-- Nhấn 's' để nhảy nhanh đến bất kỳ đâu (giống Cursor/VSCode Jump)
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			-- Nhấn 'S' để chọn nhanh các khối code (hàm, ngoặc, if/else) bằng Treesitter
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			-- Nhấn 'r' trong khi đang chọn (Visual mode) để chọn vùng bao quanh
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
		},
	},
}
