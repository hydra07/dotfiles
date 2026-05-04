return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-telescope/telescope-ui-select.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
			{
				"nvim-telescope/telescope-live-grep-args.nvim",
				version = "^1.0.0",
			},
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		keys = {
			-- ─── Core File Navigation ──────────────────────────────────
			{ ";f", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
			{
				";F",
				function()
					require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
				end,
				desc = "Find Files (All, incl hidden/ignored)",
			},
			{
				";o",
				function()
					require("telescope.builtin").oldfiles({ only_cwd = true })
				end,
				desc = "Recent Files (cwd)",
			},
			{
				";O",
				"<cmd>Telescope oldfiles<cr>",
				desc = "Recent Files (global)",
			},
			{
				";b",
				function()
					require("telescope.builtin").buffers({
						sort_mru = true,
						ignore_current_buffer = true,
					})
				end,
				desc = "Buffers (MRU)",
			},
			{ ";;", "<cmd>Telescope resume<cr>", desc = "Resume last search" },

			-- ─── Search / Grep ─────────────────────────────────────────
			{ ";r", "<cmd>Telescope live_grep<cr>", desc = "Live Grep (Simple)" },
			{
				";R",
				function()
					require("telescope").extensions.live_grep_args.live_grep_args({
						additional_args = { "--hidden" },
						cache_picker = false,
					})
				end,
				desc = "Live Grep (Args)",
			},
			{
				";g",
				function()
					require("telescope-live-grep-args.shortcuts").grep_word_under_cursor({
						postfix = "",
						quote = true,
						trim = true,
						additional_args = { "--hidden" },
						cache_picker = false,
					})
				end,
				desc = "Grep Word Under Cursor",
			},
			{
				";G",
				function()
					require("telescope-live-grep-args.shortcuts").grep_visual_selection({
						postfix = "",
						quote = true,
						trim = true,
						additional_args = { "--hidden" },
						cache_picker = false,
					})
				end,
				mode = "v",
				desc = "Grep Visual Selection",
			},

			-- ─── File Browser ──────────────────────────────────────────
			{ ";e", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", desc = "File Browser (cwd)" },
			{ ";E", "<cmd>Telescope file_browser<cr>", desc = "File Browser (root)" },

			-- ─── LSP via Telescope ─────────────────────────────────────
			{ ";s", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
			{ ";S", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace Symbols" },
			{
				"gd",
				function()
					require("telescope.builtin").lsp_definitions({ reuse_win = true })
				end,
				desc = "Go to Definition",
			},
			{
				"gr",
				function()
					require("telescope.builtin").lsp_references({ include_declaration = false })
				end,
				desc = "References",
			},
			{
				"gi",
				function()
					require("telescope.builtin").lsp_implementations({ reuse_win = true })
				end,
				desc = "Go to Implementation",
			},
			{
				"gt",
				function()
					require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
				end,
				desc = "Go to Type Definition",
			},

			-- ─── Diagnostics ───────────────────────────────────────────
			{ ";d", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics (Workspace)" },
			{ ";D", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Diagnostics (Buffer)" },
			{ ";q", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
			{ ";l", "<cmd>Telescope loclist<cr>", desc = "Location List" },

			-- ─── Git (Telescope-powered) ───────────────────────────────
			{ "<leader>gf", "<cmd>Telescope git_files<cr>", desc = "Git Files" },
			{ "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
			{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
			{ "<leader>gC", "<cmd>Telescope git_bcommits<cr>", desc = "Git Commits (Buffer)" },
			{ "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git Branches" },
			{ "<leader>gt", "<cmd>Telescope git_stash<cr>", desc = "Git Stash" },

			-- ─── Utility / Meta ────────────────────────────────────────
			{ ";k", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
			{ ";H", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
			{ ";c", "<cmd>Telescope commands<cr>", desc = "Commands" },
			{ ";m", "<cmd>Telescope marks<cr>", desc = "Marks" },
			{ ";j", "<cmd>Telescope jumplist<cr>", desc = "Jump List" },
			{ ";t", "<cmd>Telescope treesitter<cr>", desc = "Treesitter Symbols" },
			{
				";/",
				function()
					require("telescope.builtin").current_buffer_fuzzy_find({
						previewer = false,
						sorting_strategy = "ascending",
					})
				end,
				desc = "Fuzzy Find in Buffer",
			},
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
			local fb_actions = telescope.extensions.file_browser.actions
			local has_flash, flash = pcall(require, "flash")
			local function send_to_qflist_and_open(prompt_bufnr)
				actions.smart_send_to_qflist(prompt_bufnr)
				actions.open_qflist(prompt_bufnr)
			end
			local function send_selected_to_qflist_and_open(prompt_bufnr)
				actions.send_selected_to_qflist(prompt_bufnr)
				actions.open_qflist(prompt_bufnr)
			end
			local function telescope_flash(prompt_bufnr)
				if has_flash and flash.telescope then
					flash.telescope(prompt_bufnr)
					return
				end
				actions.select_default(prompt_bufnr)
			end
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
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = { prompt_position = "top", preview_width = 0.55 },
					},
					path_display = { "truncate" },
					file_ignore_patterns = {
						"%.lock$",
						"node_modules/",
						"%.git/",
					},
					cache_picker = false,
					mappings = {
						i = {
							["<C-j>"] = actions.move_selection_next,
							["<C-k>"] = actions.move_selection_previous,
							["<C-n>"] = actions.cycle_history_next,
							["<C-p>"] = actions.cycle_history_prev,
							["<C-s>"] = telescope_flash,
							["<C-q>"] = send_to_qflist_and_open,
							["<M-q>"] = send_selected_to_qflist_and_open,
							["<C-x>"] = actions.delete_buffer,
							["<Esc>"] = actions.close,
							-- Open in splits
							["<C-v>"] = actions.select_vertical,
							["<C-t>"] = actions.select_tab,
						},
						n = {
							["<C-s>"] = telescope_flash,
							["<C-q>"] = send_to_qflist_and_open,
							["<M-q>"] = send_selected_to_qflist_and_open,
							["dd"] = actions.delete_buffer,
						},
					},
				},
				pickers = {
					buffers = {
						sort_mru = true,
						ignore_current_buffer = true,
						previewer = false,
					},
					diagnostics = {
						initial_mode = "normal",
					},
					live_grep = {
						additional_args = function()
							return { "--hidden" }
						end,
					},
					oldfiles = {
						previewer = false,
					},
					lsp_references = {
						show_line = false,
					},
					lsp_definitions = {
						show_line = false,
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
					live_grep_args = {
						auto_quoting = true,
					},
					file_browser = {
						-- theme = "ivy",
						hijack_netrw = true,
						hidden = true,
						mappings = {
							["i"] = {
								["<C-a>"] = fb_actions.create, -- add
								["<C-r>"] = fb_actions.rename, -- rename
								["<C-d>"] = fb_actions.remove, -- delete
								["<A-m>"] = fb_actions.move, -- move
								["<C-h>"] = fb_actions.toggle_hidden, -- toggle hidden
							},
						},
					},
				},
			})
			-- Active extensions
			telescope.load_extension("ui-select")
			telescope.load_extension("file_browser")
			telescope.load_extension("live_grep_args")
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
				direction = "horizontal",
				close_on_exit = true,
				shell = vim.o.shell,
				float_opts = {
					border = "single",
					winblend = 0,
				},
			})
			-- Open terminal with ID
			-- Ex: 1<C-\> Open terminal 1, 2<C-\> Open terminal 2
			local function set_terminal_keymaps()
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
					set_terminal_keymaps()
				end,
			})
			vim.keymap.set("n", "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", { desc = "Terminal Float" })
			vim.keymap.set("n", "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Terminal Vertical" })
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
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
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = { "catppuccin/nvim", "nvim-tree/nvim-web-devicons" },
		config = function()
			local C = {
				blue = "#89b4fa",
				green = "#a6e3a1",
				peach = "#fab387",
				red = "#f38ba8",
				mauve = "#cba6f7",
				subtext = "#585b70",
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
				_cache.lsp = #clients > 0 and (" " .. table.concat(clients, " · ")) or ""
				_cache.fmt = #fmts > 0 and ("󰉼 " .. table.concat(fmts, " · ")) or ""
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
			local function enc_display()
				local enc = vim.bo.fileencoding
				return (enc ~= "" and enc ~= "utf-8") and enc or ""
			end

			vim.api.nvim_create_autocmd({ "BufEnter", "LspAttach", "LspDetach" }, { callback = refresh_cache })

			local ok, lualine = pcall(require, "lualine")
			if not ok then
				return
			end
			---@diagnostic disable-next-line: undefined-field
			lualine.setup({
				options = {
					section_separators = { left = "", right = "" },
					component_separators = { left = "", right = "" },
					globalstatus = true,
					refresh = { statusline = 2000 },
					always_divide_middle = true,
					disabled_filetypes = { statusline = { "dashboard", "alpha", "neo-tree", "lazy", "mason" } },
				},
				sections = {
					lualine_a = { { "mode", right_padding = 2 } },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = {
						{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
						{
							"filename",
							path = 1,
							symbols = { modified = "●", readonly = "󰌾", unnamed = "󰡯" },
						},
					},
					lualine_x = {
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
					lualine_z = { "location" },
				},
				extensions = { "neo-tree", "lazy", "mason", "toggleterm" },
			})
		end,
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			jump = {
				nohlsearch = true,
			},
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
				search = {
					enabled = true,
				},
			},
			prompts = {
				enabled = true,
				-- prefix = { { "⚡", "FlashPromptIcon" } },
			},
		},
		keys = {
			-- Press 's' to jump anywhere (like Cursor/VSCode Jump)
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			-- Press 'S' to select code blocks quickly (functions, brackets, if/else) using Treesitter
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			-- Press 'r' in visual mode to select surrounding area
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
		},
	},
}
