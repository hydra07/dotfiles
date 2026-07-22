-- Telescope core + its extensions, one file per extension under extensions/
-- (same layout as lua/plugins/lsp/: init.lua is the only file lazy.nvim scans,
-- everything under extensions/ is a plain module manually required here).
local keymaps = require("config.keymaps")
local file_browser = require("plugins.editor.telescope.extensions.file_browser")
local live_grep_args = require("plugins.editor.telescope.extensions.live_grep_args")
local frecency = require("plugins.editor.telescope.extensions.frecency")
local undo = require("plugins.editor.telescope.extensions.undo")
local fzf = require("plugins.editor.telescope.extensions.fzf")
local ui_select = require("plugins.editor.telescope.extensions.ui_select")

local extension_keys = {}
for _, ext in ipairs({ file_browser, live_grep_args, frecency, undo }) do
	for _, k in ipairs(ext.keys) do
		extension_keys[#extension_keys + 1] = k
	end
end

-- ─── Named handlers (declared above the table that wires them to keys) ─────
local function find_files_filename_priority()
	local make_entry = require("telescope.make_entry")
	-- Prefix the ordinal with the bare filename so a file matching by
	-- name ranks above files that merely live in a same-named folder.
	-- Path search still works: type "/" (e.g. "cnt005/") to filter by folder.
	local opts = { path_display = { "filename_first" } }
	local base = make_entry.gen_from_file(opts)
	opts.entry_maker = function(line)
		local entry = base(line)
		if entry then
			entry.ordinal = vim.fn.fnamemodify(line, ":t") .. " " .. entry.ordinal
		end
		return entry
	end
	require("telescope.builtin").find_files(opts)
end

local function find_files_all()
	require("telescope.builtin").find_files({ hidden = true, no_ignore = true })
end

local function oldfiles_cwd()
	require("telescope.builtin").oldfiles({ only_cwd = true })
end

local function buffers_mru()
	require("telescope.builtin").buffers({
		sort_mru = true,
		ignore_current_buffer = true,
	})
end

local function lsp_definitions()
	require("telescope.builtin").lsp_definitions({ reuse_win = true })
end

local function lsp_references()
	require("telescope.builtin").lsp_references({ include_declaration = false })
end

local function lsp_implementations()
	require("telescope.builtin").lsp_implementations({ reuse_win = true })
end

local function lsp_type_definitions()
	require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
end

local function fuzzy_find_in_buffer()
	require("telescope.builtin").current_buffer_fuzzy_find({
		previewer = false,
		sorting_strategy = "ascending",
	})
end

local core_keys = {
	-- ─── Core File Navigation ──────────────────────────────────
	-- Main picker: plain find_files (fd + fzf-native). Use ;p (frecency) for MRU-first.
	keymaps.bind("find_files_filename_priority", find_files_filename_priority),
	keymaps.bind("find_files_all", find_files_all),
	keymaps.bind("code_outline", "<cmd>Telescope aerial<cr>"),
	keymaps.bind("recent_files_cwd", oldfiles_cwd),
	keymaps.bind("recent_files_global", "<cmd>Telescope oldfiles<cr>"),
	keymaps.bind("buffers_mru", buffers_mru),
	keymaps.bind("resume_last_search", "<cmd>Telescope resume<cr>"),

	-- ─── Search / Grep ─────────────────────────────────────────
	keymaps.bind("live_grep_simple", "<cmd>Telescope live_grep<cr>"),

	-- ─── LSP via Telescope ─────────────────────────────────────
	keymaps.bind("document_symbols", "<cmd>Telescope lsp_document_symbols<cr>"),
	keymaps.bind("workspace_symbols", "<cmd>Telescope lsp_workspace_symbols<cr>"),
	keymaps.bind("goto_definition", lsp_definitions),
	keymaps.bind("goto_references", lsp_references),
	keymaps.bind("goto_implementation", lsp_implementations),
	keymaps.bind("goto_type_definition", lsp_type_definitions),

	-- ─── Diagnostics ───────────────────────────────────────────
	keymaps.bind("diagnostics_workspace", "<cmd>Telescope diagnostics<cr>"),
	keymaps.bind("diagnostics_buffer", "<cmd>Telescope diagnostics bufnr=0<cr>"),
	keymaps.bind("quickfix_list", "<cmd>Telescope quickfix<cr>"),
	keymaps.bind("location_list", "<cmd>Telescope loclist<cr>"),

	-- ─── Git (Telescope-powered) ───────────────────────────────
	keymaps.bind("git_files", "<cmd>Telescope git_files<cr>"),
	keymaps.bind("git_status", "<cmd>Telescope git_status<cr>"),
	keymaps.bind("git_commits", "<cmd>Telescope git_commits<cr>"),
	keymaps.bind("git_commits_buffer", "<cmd>Telescope git_bcommits<cr>"),
	keymaps.bind("git_branches", "<cmd>Telescope git_branches<cr>"),
	keymaps.bind("git_stash", "<cmd>Telescope git_stash<cr>"),

	-- ─── Utility / Meta ────────────────────────────────────────
	keymaps.bind("list_keymaps", "<cmd>Telescope keymaps<cr>"),
	keymaps.bind("help_tags", "<cmd>Telescope help_tags<cr>"),
	keymaps.bind("list_commands", "<cmd>Telescope commands<cr>"),
	keymaps.bind("list_marks", "<cmd>Telescope marks<cr>"),
	keymaps.bind("jump_list", "<cmd>Telescope jumplist<cr>"),
	keymaps.bind("treesitter_symbols", "<cmd>Telescope treesitter<cr>"),
	keymaps.bind("fuzzy_find_in_buffer", fuzzy_find_in_buffer),
	keymaps.bind("command_palette", "<cmd>Telescope keymaps<cr>"),
}

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
		keys = vim.list_extend(vim.deepcopy(core_keys), extension_keys),
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")
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
				-- Synchronous fs_stat (a few µs) — avoids nvim API calls inside a libuv
				-- fast-event callback, which would make the preview flaky/error out.
				local stat = vim.uv.fs_stat(filepath)
				if stat and (stat.size > 262144 or filepath:match("%.min%.") or filepath:match("-lock%.")) then
					vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "File too large or minified to preview" })
					return
				end
				previewers.buffer_previewer_maker(filepath, bufnr, opts)
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
					-- No global debounce: fuzzy pickers (find_files/buffers) are already
					-- instant via fzf-native, debouncing would just add perceived lag.
					-- Debounce is set per-picker below for live_grep (spawns rg per keystroke).
					buffer_previewer_maker = custom_previewer_maker,
					preview = {
						filesize_limit = 0.25,
						timeout = 250,
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
						debounce = 100, -- batch keystrokes to avoid spawning rg constantly
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
					["ui-select"] = ui_select.settings(),
					live_grep_args = live_grep_args.settings(),
					file_browser = file_browser.settings(),
					fzf = fzf.settings(),
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
}
