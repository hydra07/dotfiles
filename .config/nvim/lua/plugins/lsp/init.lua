-- LSP entry point
-- To add a new language: create a new file in configs/, require it in servers.lua
local utils = require("plugins.lsp.utils")
local servers = require("plugins.lsp.servers")

-- Prepend Mason bin directory to PATH so Neovim/LSP/formatters always find it
local path_sep = vim.uv.os_uname().sysname == "Windows_NT" and ";" or ":"
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. path_sep .. vim.env.PATH

return {
	-- ── Mason: UI only ────────────────────────────────────────────────────
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		opts = {
			ui = {
				border = "single",
				icons = {
					package_installed = "●",
					package_pending = "○",
					package_uninstalled = "○",
				},
			},
		},
	},

	-- ── Tool installer: manual only ───────────────────────────────────────
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
		opts = {
			ensure_installed = {
				"stylua",
				"prettierd",
				"black",
				"shfmt",
				"eslint_d",
				"shellcheck",
			},
			auto_update = false,
			run_on_start = false,
		},
	},

	-- ── Mason-lspconfig: server installation ──────────────────────────────
	{
		"williamboman/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				"vtsls",
				"eslint",
				"basedpyright",
				"lua_ls",
				"rust_analyzer",
				"emmet_language_server",
				"tailwindcss",
			},
			automatic_installation = false,
			automatic_enable = false,
		},
	},

	-- ── Lazydev: optimizes Lua LSP for Neovim config ──────────────────────
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- ── Core LSP ──────────────────────────────────────────────────────────
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		cmd = { "LspInfo", "LspStart", "LspStop", "LspRestart", "LspInstall" },
		config = function()
			require("lspconfig")
			-- 1. Shared config for all servers
			vim.lsp.config("*", {
				capabilities = utils.capabilities(),
				root_markers = {
					".git",
					"package.json",
					"Cargo.toml",
					"go.mod",
					"pyproject.toml",
					"setup.py",
				},
			})

			-- 2. Register settings and enable all servers defined in servers.lua
			for name, config in pairs(servers) do
				vim.lsp.config(name, config)
				vim.lsp.enable(name)
			end

			-- 3. UI
			if vim.o.winborder == "" then
				vim.o.winborder = "single"
			end

			-- 4. Setup diagnostics, attach logic, keymaps
			utils.setup_diagnostics()
			utils.setup_attach()
			utils.setup_keymaps()
		end,
	},
}

