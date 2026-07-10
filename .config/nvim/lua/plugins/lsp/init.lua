-- LSP entry point
-- To add a new language: create a new file in configs/, require it in servers.lua
local utils = require("plugins.lsp.utils")
local servers = require("plugins.lsp.servers")

-- ── Tool resolution PATH (LSP servers + conform formatters cùng dùng) ──────
-- Thứ tự ưu tiên: mise shims (nếu có) > mason/bin > PATH hệ thống sẵn có.
--   • mise shims: entry-point resolve version theo cwd lúc gọi -> node/bun/pnpm
--     đúng bản mà từng project pin, kể cả khi nhảy giữa nhiều project trong 1
--     phiên nvim (nơi `mise activate` của shell không áp được). Đây là cách mise
--     khuyến nghị cho editor. Không có mise -> giữ nguyên hành vi cũ (mason + PATH).
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
	table.insert(path_parts, 1, shims) -- mise ưu tiên -> đứng đầu
end
vim.env.PATH = table.concat(path_parts, path_sep) .. path_sep .. vim.env.PATH

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
			-- KHÔNG require("lspconfig"): module đó deprecated ở bản mới.
			-- Ta dùng thẳng vim.lsp.config/enable; các lsp/<name>.lua của
			-- nvim-lspconfig vẫn tự nạp từ runtimepath khi reference tên server.
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

