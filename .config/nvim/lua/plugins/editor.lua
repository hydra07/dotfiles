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
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = vim.fn.has("win32") == 1
					and "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release"
					or "make",
			},
			"nvim-telescope/telescope-frecency.nvim",
			"debugloop/telescope-undo.nvim",
		},
		keys = {
			-- ─── Core File Navigation ──────────────────────────────────
			{ ";f", "<cmd>Telescope frecency workspace=CWD<cr>", desc = "Find Files (Frecency)" },
			{
				";F",
				function()
					require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
				end,
				desc = "Find Files (All, incl hidden/ignored)",
			},
			{ ";u", "<cmd>Telescope undo<cr>", desc = "Undo History" },
			{ ";a", "<cmd>Telescope aerial<cr>", desc = "Code Outline (Aerial)" },
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

			-- Custom high-performance buffer previewer maker
			local previewers = require("telescope.previewers")
			local custom_previewer_maker = function(filepath, bufnr, opts)
				opts = opts or {}
				filepath = vim.fn.expand(filepath)
				vim.loop.fs_stat(filepath, function(err, stat)
					if not err and stat then
						if stat.size > 102400 or filepath:match("%.min%.") or filepath:match("-lock%.") then
							vim.schedule(function()
								vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "File too large or minified to preview" })
							end)
							return
						end
					end
					previewers.buffer_previewer_maker(filepath, bufnr, opts)
				end)
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
					debounce = 150,
					buffer_previewer_maker = custom_previewer_maker,
					preview = {
						filesize_limit = 0.1,
						timeout = 150,
					},
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
						hijack_netrw = true,
						hidden = true,
						mappings = {
							["i"] = {
								["<C-a>"] = fb_actions.create,
								["<C-r>"] = fb_actions.rename,
								["<C-d>"] = fb_actions.remove,
								["<A-m>"] = fb_actions.move,
								["<C-h>"] = fb_actions.toggle_hidden,
							},
						},
					},
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
				},
			})
			telescope.load_extension("ui-select")
			telescope.load_extension("file_browser")
			telescope.load_extension("live_grep_args")
			telescope.load_extension("fzf")
			telescope.load_extension("frecency")
			telescope.load_extension("undo")
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
					border = "rounded",
					winblend = 10,
				},
			})
			local function set_terminal_keymaps()
				local opts = { buffer = 0 }
				vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], opts)
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
			vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
				pattern = "term://*",
				callback = function()
					vim.cmd("startinsert")
				end,
			})
			for i = 1, 9 do
				vim.keymap.set({ "n", "t" }, "<leader>t" .. i, string.format("<cmd>%dToggleTerm<cr>", i), { desc = "Toggle Terminal " .. i })
			end
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
					visible = true,
					hide_dotfiles = false,
				},
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
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
				subtext = "#a6adc8",
				bg = "#1e1e2e",
				surface0 = "#313244",
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
				_cache.lsp = #clients > 0 and (" " .. table.concat(clients, "·")) or ""
				_cache.fmt = #fmts > 0 and ("󰉼 " .. table.concat(fmts, "·")) or ""
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
				if not ok then return "" end
				local terms = toggleterm.get_all()
				if #terms == 0 then return "" end
				local active_buf = vim.api.nvim_get_current_buf()
				local parts = {}
				for _, term in ipairs(terms) do
					local is_current = (term.bufnr == active_buf)
					local is_open = term:is_open()
					local state = ""
					if is_current then
						state = "*"
					elseif is_open then
						state = "⚡"
					else
						state = "💤"
					end
					table.insert(parts, string.format("%d%s", term.id, state))
				end
				return "  " .. table.concat(parts, "·")
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
					section_separators = { left = "", right = "" },
					component_separators = { left = "", right = "" },
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
						{ "branch", icon = "" },
						"diff",
						{ "diagnostics", symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " } },
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
	{
		"stevearc/aerial.nvim",
		cmd = { "AerialToggle", "AerialNavToggle", "AerialInfo" },
		opts = {
			on_attach = function(bufnr)
				vim.keymap.set("n", "{", "<cmd>AerialPrev<cr>", { buffer = bufnr })
				vim.keymap.set("n", "}", "<cmd>AerialNext<cr>", { buffer = bufnr })
			end,
		},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},
	{
		"stevearc/dressing.nvim",
		opts = {},
	},
}
