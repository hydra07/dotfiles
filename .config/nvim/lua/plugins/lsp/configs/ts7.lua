-- ts7 — TypeScript 7 native (Go) as the editor's OWN, separate LSP.
--
-- Model (like VSCode): the editor has its own TS engine, INDEPENDENT of the
-- project's `typescript` dependency. Here the engine is the global native TS7;
-- the project can still pin typescript@6 for build/CI. The only thing read
-- from the project is tsconfig.json (for compilerOptions + @/ paths) — the
-- engine that actually runs is the editor's own TS7.
--
-- Binary: install globally with `npm i -g @typescript/native-preview` (provides
-- `tsgo`). Same Go binary as typescript@7 stable's `tsc`, just a different bin name.
-- The binary speaks LSP itself via `--lsp --stdio` -> no need for a custom host.
--
-- Fully self-contained (doesn't reuse lspconfig's base) so it NEVER falls back
-- to the project's node_modules/.bin -> always uses the editor's own TS7.

local shared = require("plugins.lsp.configs._ts_shared")

-- Prefer the native .exe (standalone, no node needed, spawns reliably on Windows),
-- fall back to exepath on PATH for other environments (WSL/Linux). The win32
-- branch globs the mise node install tree, which costs ~20ms — only pay that
-- on Windows, and only once the client is actually about to spawn (below),
-- not on every Neovim startup regardless of whether a TS/JS file is opened.
local function resolve_tsgo()
	if vim.fn.has("win32") == 1 then
		local pat = vim.fn.expand("~/AppData/Local/mise/installs/node/*/node_modules/@typescript/**/tsgo*.exe")
		local hits = vim.fn.glob(pat, true, true)
		if hits[1] then
			return hits[1]
		end
	end
	local p = vim.fn.exepath("tsgo")
	return p ~= "" and p or "tsgo"
end

return {
	-- `cmd` as a function defers resolve_tsgo() to actual client-spawn time
	-- (Neovim only calls this once a .ts/.js buffer triggers the client to
	-- start) instead of running it eagerly when this config file is required
	-- at Neovim startup. Must call vim.lsp.rpc.start itself here — returning
	-- a function makes Neovim treat the return value as the RPC client
	-- object, not a plain argv table.
	cmd = function(dispatchers, config)
		return require("vim.lsp.rpc").start({ resolve_tsgo(), "--lsp", "--stdio" }, dispatchers, {
			cwd = config.cmd_cwd,
			env = config.cmd_env,
		})
	end,
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	-- Anchor root to tsconfig/jsconfig (where @/ paths live), then package.json/.git.
	root_markers = shared.root_markers,
	settings = {
		typescript = {
			preferences = {
				importModuleSpecifier = "non-relative",
				importModuleSpecifierEnding = "minimal",
			},
			inlayHints = shared.inlay_hints,
		},
		javascript = {
			preferences = {
				importModuleSpecifier = "non-relative",
				importModuleSpecifierEnding = "minimal",
			},
		},
	},
}
