-- Single home for all keymaps that don't need a plugin's lazy-load `keys` trigger.
-- Plugin-triggering keymaps (Telescope, Neo-tree, toggleterm, flash, grug-far, conform)
-- stay in their own plugin spec's `keys = {}` — that's what makes lazy.nvim load them on demand.
local map = vim.keymap.set

-- Navigation: wrapped-line motion
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Move Down (wrapped lines)", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Move Up (wrapped lines)", expr = true, silent = true })

-- Diagnostics navigation
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

-- Move lines/blocks
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move Block Down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move Block Up" })
map("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move Line Down" })
map("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move Line Up" })
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move Block Down" })
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move Block Up" })
map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Line Down" })
map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Line Up" })

-- Window navigation (works in normal buffers and terminal buffers alike)
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Bottom Window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Top Window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to Lower Window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Upper Window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to Right Window" })

-- Window resize
map("n", "<M-h>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<M-j>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<M-k>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<M-l>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Insert-mode cursor movement
map("i", "<M-h>", "<Left>", { desc = "Move Left" })
map("i", "<M-j>", "<Down>", { desc = "Move Down" })
map("i", "<M-k>", "<Up>", { desc = "Move Up" })
map("i", "<M-l>", "<Right>", { desc = "Move Right" })

-- File & save
map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
map("n", "<leader>fs", "<cmd>w<cr>", { desc = "Save File" })
map("n", "<leader>fS", "<cmd>wa<cr>", { desc = "Save All" })
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- Window / split management
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split Vertical" })
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split Horizontal" })
map("n", "<leader>wd", "<cmd>close<cr>", { desc = "Close Window" })
map("n", "<leader>wD", "<cmd>only<cr>", { desc = "Close Other Windows" })

-- Buffer management
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })

local function close_other_buffers()
	local current = vim.api.nvim_get_current_buf()
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if bufnr ~= current and vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buflisted then
			pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
		end
	end
	vim.notify("Closed other buffers", vim.log.levels.INFO)
end
map("n", "<leader>bD", close_other_buffers, { desc = "Close Other Buffers" })

-- Code / LSP (core vim.lsp.buf.* + cmd-stub-safe commands, work with zero clients attached)
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
map("n", "<leader>cl", "<cmd>LspInfo<cr>", { desc = "LSP Information" })
map("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason Manager" })

-- Diagnostics: detail / copy to clipboard
local function fmt_diagnostic(d, bufnr)
	local fname = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")
	local sev = vim.diagnostic.severity[d.severity] or "?"
	local src = d.source and (" " .. d.source) or ""
	local code = d.code and (" (" .. d.code .. ")") or ""
	return string.format(
		"%s:%d:%d [%s]%s%s %s",
		fname,
		d.lnum + 1,
		d.col + 1,
		sev,
		src,
		code,
		d.message:gsub("%s+", " ")
	)
end

local function copy_diag(lines, label)
	if not lines or #lines == 0 then
		vim.notify("No diagnostics", vim.log.levels.INFO)
		return
	end
	local text = table.concat(lines, "\n")
	vim.fn.setreg("+", text)
	vim.fn.setreg('"', text)
	vim.notify("Copied " .. label, vim.log.levels.INFO, { title = "Diagnostics" })
end

local function diagnostics_detail()
	vim.diagnostic.open_float(nil, { focus = true, scope = "line" })
end
map("n", "<leader>ld", diagnostics_detail, { desc = "Diagnostics: Detail" })

local function copy_line_diagnostics()
	local buf = vim.api.nvim_get_current_buf()
	local line = vim.api.nvim_win_get_cursor(0)[1] - 1
	local diags = vim.diagnostic.get(buf, { lnum = line })
	copy_diag(
		vim.tbl_map(function(d)
			return fmt_diagnostic(d, buf)
		end, diags),
		"line diagnostics"
	)
end
map("n", "<leader>ly", copy_line_diagnostics, { desc = "Diagnostics: Copy line" })

local function copy_buffer_diagnostics()
	local buf = vim.api.nvim_get_current_buf()
	local diags = vim.diagnostic.get(buf)
	table.sort(diags, function(a, b)
		return a.lnum == b.lnum and a.col < b.col or a.lnum < b.lnum
	end)
	copy_diag(
		vim.tbl_map(function(d)
			return fmt_diagnostic(d, buf)
		end, diags),
		"buffer diagnostics"
	)
end
map("n", "<leader>lY", copy_buffer_diagnostics, { desc = "Diagnostics: Copy buffer" })

local function toggle_inlay_hints()
	local bufnr = vim.api.nvim_get_current_buf()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
end
map("n", ";h", toggle_inlay_hints, { desc = "LSP: Toggle inlay hints" })

-- which-key loads on VeryLazy (not a `keys` trigger), so requiring it here is safe
local function show_buffer_local_keymaps()
	local ok, wk = pcall(require, "which-key")
	if ok then
		wk.show({ global = false })
	end
end
map("n", "<leader>?", show_buffer_local_keymaps, { desc = "Buffer Local Keymaps" })

-- ─── Keymap registry ────────────────────────────────────────────────────
-- Every keybinding that a plugin file registers via its lazy `keys = {}`
-- table is named here, once, with its key + description. Plugin files call
-- `keymaps.bind("name", action)` and supply only the action (a command
-- string or function) — so replacing the plugin behind a key later only
-- means changing the action at the call site, never re-typing the key/desc.
local registry = {
	-- Telescope (core)
	find_files_filename_priority = { ";f", "Find Files (filename priority)" },
	find_files_all = { ";F", "Find Files (All, incl hidden/ignored)" },
	code_outline = { ";a", "Code Outline (Aerial)" },
	recent_files_cwd = { ";o", "Recent Files (cwd)" },
	recent_files_global = { ";O", "Recent Files (global)" },
	buffers_mru = { ";b", "Buffers (MRU)" },
	resume_last_search = { ";;", "Resume last search" },
	live_grep_simple = { ";r", "Live Grep (Simple)" },
	document_symbols = { ";s", "Document Symbols" },
	workspace_symbols = { ";S", "Workspace Symbols" },
	goto_definition = { "gd", "Go to Definition" },
	goto_references = { "gr", "References" },
	goto_implementation = { "gi", "Go to Implementation" },
	goto_type_definition = { "gt", "Go to Type Definition" },
	diagnostics_workspace = { ";d", "Diagnostics (Workspace)" },
	diagnostics_buffer = { ";D", "Diagnostics (Buffer)" },
	quickfix_list = { ";q", "Quickfix List" },
	location_list = { ";l", "Location List" },
	git_files = { "<leader>gf", "Git Files" },
	git_status = { "<leader>gs", "Git Status" },
	git_commits = { "<leader>gc", "Git Commits" },
	git_commits_buffer = { "<leader>gC", "Git Commits (Buffer)" },
	git_branches = { "<leader>gb", "Git Branches" },
	git_stash = { "<leader>gt", "Git Stash" },
	list_keymaps = { ";k", "Keymaps" },
	help_tags = { ";H", "Help Tags" },
	list_commands = { ";c", "Commands" },
	list_marks = { ";m", "Marks" },
	jump_list = { ";j", "Jump List" },
	treesitter_symbols = { ";t", "Treesitter Symbols" },
	fuzzy_find_in_buffer = { ";/", "Fuzzy Find in Buffer" },
	command_palette = { "<leader>p", "Command Palette (Search Keymaps)" },

	-- Telescope extensions
	file_browser_cwd = { ";e", "File Browser (cwd)" },
	file_browser_root = { ";E", "File Browser (root)" },
	live_grep_args = { ";R", "Live Grep (Args)" },
	grep_word_under_cursor = { ";g", "Grep Word Under Cursor" },
	grep_visual_selection = { ";G", "Grep Visual Selection", "v" },
	find_files_frecency = { ";p", "Find Files (Frecency)" },
	undo_history = { ";u", "Undo History" },

	-- Terminal (toggleterm)
	toggle_terminal = { [[<C-\>]], "Toggle Terminal" },
	terminal_horizontal = { "<leader>th", "Terminal Horizontal" },
	terminal_float = { "<leader>tf", "Terminal Float" },
	terminal_vertical = { "<leader>tv", "Terminal Vertical" },
	terminal_select = { "<leader>ts", "Select Terminal" },
	terminal_toggle_all = { "<leader>tt", "Toggle All Terminals" },

	-- File explorer (neo-tree)
	toggle_explorer = { "<leader>e", "Explorer NeoTree (Root Dir)" },

	-- Motion (flash)
	flash_jump = { "s", "Flash", { "n", "x", "o" } },
	flash_treesitter = { "S", "Flash Treesitter", { "n", "x", "o" } },
	flash_remote = { "r", "Remote Flash", "o" },
	flash_treesitter_search = { "R", "Treesitter Search", { "o", "x" } },

	-- Formatting (conform)
	format_buffer = { "<leader>cf", "Format Buffer" },
	conform_info = { "<leader>ci", "Conform Info" },

	-- Code outline (aerial) — buffer-local, set from its on_attach
	aerial_prev = { "{", "Aerial: Previous Symbol" },
	aerial_next = { "}", "Aerial: Next Symbol" },

	-- Git hunks (gitsigns) — buffer-local, set from its on_attach
	git_next_hunk = { "]c", "Next Git Change" },
	git_prev_hunk = { "[c", "Prev Git Change" },
	git_stage_hunk = { "<leader>ghs", "Stage Hunk" },
	git_reset_hunk = { "<leader>ghr", "Reset Hunk" },
	git_stage_hunk_visual = { "<leader>ghs", "Stage Selected Hunk", "v" },
	git_reset_hunk_visual = { "<leader>ghr", "Reset Selected Hunk", "v" },
	git_stage_buffer = { "<leader>ghS", "Stage Buffer" },
	git_undo_stage_hunk = { "<leader>ghu", "Undo Stage Hunk" },
	git_reset_buffer = { "<leader>ghR", "Reset Buffer" },
	git_preview_hunk = { "<leader>ghp", "Preview Hunk Inline" },
	git_blame_line = { "<leader>ghb", "Git Blame Line" },
	git_toggle_line_blame = { "<leader>ghB", "Toggle Git Blame Line" },
	git_diff_this = { "<leader>ghd", "Diff This" },
	git_diff_this_tilde = { "<leader>ghD", "Diff This ~" },
	git_hunk_textobject = { "ih", "Git Hunk", { "o", "x" } },

	-- Terminal exit-to-normal-mode — buffer-local, set on TermOpen
	terminal_exit_escape = { "<Esc><Esc>", "Exit Terminal Mode", "t" },
	terminal_exit_jk = { "jk", "Exit Terminal Mode", "t" },
}
for i = 1, 9 do
	registry["terminal_" .. i] = { "<leader>t" .. i, "Toggle Terminal " .. i, { "n", "t" } }
end

--- Look up a registered { key, desc[, mode] } and attach the given action.
--- Plugin files use this instead of writing the key/desc themselves.
local function bind(name, action, extra)
	local entry = registry[name]
	assert(entry, "keymaps.bind: no such key '" .. name .. "'")
	local spec = { entry[1], action, desc = entry[2] }
	if entry[3] then
		spec.mode = entry[3]
	end
	return vim.tbl_extend("force", spec, extra or {})
end

--- Same registry, for the buffer-local case (on_attach/TermOpen handlers):
--- sets the keymap immediately, scoped to `bufnr`, instead of returning a
--- lazy `keys` entry. `extra` can carry options bind() can't (e.g. expr = true).
local function set_buffer(name, action, bufnr, extra)
	local entry = registry[name]
	assert(entry, "keymaps.set_buffer: no such key '" .. name .. "'")
	local opts = vim.tbl_extend("force", { buffer = bufnr, desc = entry[2] }, extra or {})
	vim.keymap.set(entry[3] or "n", entry[1], action, opts)
end

return { bind = bind, set_buffer = set_buffer }
