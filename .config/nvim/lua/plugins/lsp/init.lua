local utils = require("plugins.lsp.utils")
local servers = require("plugins.lsp.servers")
local is_win = vim.uv.os_uname().sysname == "Windows_NT"
local path_sep = is_win and ";" or ":"

local function mise_shims_dir()
	local data = vim.env.MISE_DATA_DIR
	if not data or data == "" then
		if is_win then
			data = vim.fn.expand("~/AppData/Local/mise")
		elseif vim.env.XDG_DATA_HOME and vim.env.XDG_DATA_HOME ~= "" then
			data = vim.env.XDG_DATA_HOME .. "/mise"
		else
			data = vim.fn.expand("~/.local/share/mise")
		end
	end
	local shims = data .. (is_win and "\\shims" or "/shims")
	return vim.fn.isdirectory(shims) == 1 and shims or nil
end

local path_parts = { vim.fn.stdpath("data") .. "/mason/bin" }
local shims = mise_shims_dir()
if shims then
	table.insert(path_parts, 1, shims) -- mise takes priority -> goes first
end
vim.env.PATH = table.concat(path_parts, path_sep) .. path_sep .. vim.env.PATH

return {
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
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		cmd = { "LspInfo", "LspStart", "LspStop", "LspRestart", "LspInstall" },
		config = function()
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
			for name, config in pairs(servers) do
				-- Isolate per-server registration: a bug in one server's config file
				-- shouldn't stop the others from being registered.
				local ok, err = pcall(function()
					vim.lsp.config(name, config)
					vim.lsp.enable(name)
				end)
				if not ok then
					vim.notify(("LSP server '%s' failed to register: %s"):format(name, err), vim.log.levels.ERROR)
				end
			end
			if vim.o.winborder == "" then
				vim.o.winborder = "single"
			end
			utils.setup_diagnostics()
			utils.setup_attach()
		end,
	},
}
