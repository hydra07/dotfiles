return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "helix",
			plugins = {
				marks = true,
				registers = true,
				spelling = { enabled = true, suggestions = 20 },
			},
			win = {
				border = "single",
				padding = { 1, 2 },
				title_pos = "center",
				wo = { winblend = 30 },
			},
			icons = {
				breadcrumb = "»",
				separator = "➜",
				group = "+",
			},
			spec = {
				{ "<leader>f", group = "File/Find" },
				{ "<leader>e", desc = "Explorer" },
				{ "<leader>s", group = "Flash/Jump", icon = "⚡" },
				{ "<leader>g", group = "Git", icon = "" },
				{ "<leader>l", group = "LSP" },
				{ "<leader>w", group = "Window/Split" },
				{ "<leader>b", group = "Buffer" },
				{ "<leader>v", group = "Neovide" },
				{ "<leader>t", group = "Terminal" },
				{ "<leader>c", group = "Code/Copilot" },
				{ ";", group = "Telescope", icon = "" },
				{ ";h", desc = "Toggle Inlay Hints" },
				{ "g", group = "Go to / LSP Navigate" },
			},
		},
		keys = {
			-- Move block up/down in Visual Mode with J/K
			{ "J", ":m '>+1<cr>gv=gv", desc = "Move Block Down", mode = "v" },
			{ "K", ":m '<-2<cr>gv=gv", desc = "Move Block Up", mode = "v" },
			{ "<A-Down>", "<cmd>m .+1<cr>== ", desc = "Move Line Down" },
			{ "<A-Up>", "<cmd>m .-2<cr>== ", desc = "Move Line Up" },
			{ "<A-Down>", ":m '>+1<cr>gv=gv", desc = "Move Block Down", mode = "v" },
			{ "<A-Up>", ":m '<-2<cr>gv=gv", desc = "Move Block Up", mode = "v" },
			{ "<A-Down>", "<esc><cmd>m .+1<cr>==gi", desc = "Move Line Down", mode = "i" },
			{ "<A-Up>", "<esc><cmd>m .-2<cr>==gi", desc = "Move Line Up", mode = "i" },
			-- Navigation
			{ "<C-h>", "<C-w>h", desc = "Go to Left Window" },
			{ "<C-j>", "<C-w>j", desc = "Go to Bottom Window" },
			{ "<C-k>", "<C-w>k", desc = "Go to Top Window" },
			{ "<C-l>", "<C-w>l", desc = "Go to Right Window" },
			{ "<C-h>", "<cmd>wincmd h<cr>", desc = "Go to Left Window", mode = "t" },
			{ "<C-j>", "<cmd>wincmd j<cr>", desc = "Go to Lower Window", mode = "t" },
			{ "<C-k>", "<cmd>wincmd k<cr>", desc = "Go to Upper Window", mode = "t" },
			{ "<C-l>", "<cmd>wincmd l<cr>", desc = "Go to Right Window", mode = "t" },
			{ "<M-h>", "<Left>", desc = "Move Left", mode = "i" },
			{ "<M-j>", "<Down>", desc = "Move Down", mode = "i" },
			{ "<M-k>", "<Up>", desc = "Move Up", mode = "i" },
			{ "<M-l>", "<Right>", desc = "Move Right", mode = "i" },
			-- 1. FILE & SAVE
			{
				"<C-s>",
				"<cmd>w<cr><esc>",
				desc = "Save File",
				mode = { "n", "i", "v" },
			},
			{
				"<leader>fs",
				"<cmd>w<cr>",
				desc = "Save File",
			},
			{
				"<leader>fS",
				"<cmd>wa<cr>",
				desc = "Save All",
			},
			{
				"<leader>fn",
				"<cmd>enew<cr>",
				desc = "New File",
			},
			-- 2. WINDOW & SPLIT
			{
				"<leader>wv",
				"<cmd>vsplit<cr>",
				desc = "Split Vertical",
			},
			{
				"<leader>ws",
				"<cmd>split<cr>",
				desc = "Split Horizontal",
			},
			{
				"<leader>wd",
				"<cmd>close<cr>",
				desc = "Close Window",
			},
			{
				"<leader>wo",
				"<cmd>only<cr>",
				desc = "Close Others",
			},
			-- 3. BUFFER MANAGEMENT
			{
				"<leader>bn",
				"<cmd>bnext<cr>",
				desc = "Next Buffer",
			},
			{
				"<leader>bp",
				"<cmd>bprevious<cr>",
				desc = "Prev Buffer",
			},
			{
				"<leader>bd",
				"<cmd>bdelete<cr>",
				desc = "Delete Buffer",
			},
			-- 4. NEOVIDE GUI OPTIMIZATION
			{
				"<leader>v+",
				function()
					vim.g.neovide_opacity = math.min(vim.g.neovide_opacity + 0.05, 1)
				end,
				desc = "Increase Transparency",
			},
			{
				"<leader>v-",
				function()
					vim.g.neovide_opacity = math.max(vim.g.neovide_opacity - 0.05, 0)
				end,
				desc = "Decrease Transparency",
			},
			{
				"<C-=>", -- Ctrl + = to increase font size
				function()
					local current_font = vim.o.guifont
					local name, size = current_font:match("([^:]+):h(%d+)")
					if name and size then
						vim.o.guifont = name .. ":h" .. (tonumber(size) + 1)
					end
				end,
				desc = "Increase Font Size",
			},
			{
				"<C-->", -- Ctrl + - to decrease font size
				function()
					local current_font = vim.o.guifont
					local name, size = current_font:match("([^:]+):h(%d+)")
					if name and size then
						local new_size = tonumber(size) - 1
						if new_size > 0 then
							vim.o.guifont = name .. ":h" .. new_size
						end
					end
				end,
				desc = "Decrease Font Size",
			},
			{
				"<C-0>", -- Ctrl + 0 to reset font size to 13
				function()
					local current_font = vim.o.guifont
					local name = current_font:match("([^:]+):h%d+")
					if name then
						vim.o.guifont = name .. ":h13"
					end
				end,
				desc = "Reset Font Size",
			},
			-- 5. LSP & CODE
			{
				"<leader>la",
				vim.lsp.buf.code_action,
				desc = "Code Action",
			},
			{
				"<leader>lr",
				vim.lsp.buf.rename,
				desc = "Rename Symbol",
			},
			{
				"<leader>li",
				"<cmd>LspInfo<cr>",
				desc = "LSP Information",
			},
			{
				"<leader>lm",
				"<cmd>Mason<cr>",
				desc = "Mason Manager",
			},
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" }, function(err, did_edit)
						if err then
							vim.notify("Format failed: " .. err, vim.log.levels.ERROR, { title = "Conform" })
							return
						end
						if did_edit then
							vim.notify("Formatted buffer", vim.log.levels.INFO, { title = "Conform" })
						else
							vim.notify("No formatting changes", vim.log.levels.INFO, { title = "Conform" })
						end
					end)
				end,
				desc = "Format Buffer",
			},
			{ "<leader>ci", "<cmd>ConformInfo<cr>", desc = "Conform Info" },
			-- 6. TERMINAL
			{ "<leader>t1", "<cmd>1ToggleTerm direction=horizontal<cr>", desc = "Terminal 1 (Down)" },
			{ "<leader>t2", "<cmd>2ToggleTerm direction=vertical<cr>", desc = "Terminal 2 (Side)" },
			{ "<leader>t3", "<cmd>3ToggleTerm direction=float<cr>", desc = "Terminal 3 (Float)" },
			{ "<leader>ts", "<cmd>TermSelect<cr>", desc = "Select Terminal" },
			{ "<leader>tt", "<cmd>ToggleTermToggleAll<cr>", desc = "Toggle All Terminals" },
			-- 7. Helpful Shortcuts
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps",
			},
		},
	},
}
