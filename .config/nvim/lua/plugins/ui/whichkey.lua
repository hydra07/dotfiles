return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "helix",
			delay = 0,
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
				group = "",
			},
			-- Only group/prefix labels here — which-key already reads `desc` off
			-- the real keymaps (config/keymaps.lua, telescope/, neotree.lua, ...),
			-- so per-key entries would just duplicate it and drift out of sync.
			spec = {
				{ "<leader>f", group = "File/Save" },
				{ "<leader>s", group = "Search/Jump", icon = "⚡" },
				{ "<leader>g", group = "Git", icon = "" },
				{ "<leader>gh", group = "Git Hunk" },
				{ "<leader>c", group = "Code/LSP" },
				{ "<leader>w", group = "Window" },
				{ "<leader>b", group = "Buffer" },
				{ "<leader>v", group = "Neovide" },
				{ "<leader>t", group = "Terminal" },
				{ ";", group = "Telescope", icon = "" },
				{ "g", group = "Go to / LSP Navigate" },
			},
		},
	},
}
