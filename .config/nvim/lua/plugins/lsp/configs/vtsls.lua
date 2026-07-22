-- vtsls (TypeScript/JavaScript) Configuration
local shared = require("plugins.lsp.configs._ts_shared")

return {
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	-- Prefer tsconfig/jsconfig to anchor to the exact package declaring the (@/)
	-- path alias in a monorepo, before falling back to package.json/.git.
	root_markers = shared.root_markers,
	settings = {
		typescript = {
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
			preferences = {
				jsxAttributeCompletionStyle = "auto",
				-- vtsls reads the VS Code-style key "importModuleSpecifier" (NOT
				-- the raw tsserver protocol's "importModuleSpecifierPreference").
				-- "non-relative": always prefer the @/ alias from tsconfig paths.
				importModuleSpecifier = "non-relative",
				importModuleSpecifierEnding = "minimal",
			},
			inlayHints = shared.inlay_hints,
		},
		javascript = {
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
			preferences = {
				jsxAttributeCompletionStyle = "auto",
				importModuleSpecifierPreference = "shortest",
				importModuleSpecifierEnding = "minimal",
			},
			inlayHints = shared.inlay_hints,
		},
		vtsls = {
			enableMoveToFileCodeAction = true,
			autoUseWorkspaceTsdk = true,
			tsserver = {
				globalPlugins = {},
				maxTsServerMemory = 8192,
			},
			experimental = {
				completion = {
					enableServerSideFuzzyMatch = true,
					entriesLimit = 100,
				},
			},
		},
	},
}
