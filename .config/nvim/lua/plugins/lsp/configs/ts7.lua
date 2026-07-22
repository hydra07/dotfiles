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
-- fall back to exepath on PATH for other environments (WSL/Linux).
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
	cmd = { resolve_tsgo(), "--lsp", "--stdio" },
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
