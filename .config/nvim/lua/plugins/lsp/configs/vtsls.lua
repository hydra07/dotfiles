-- vtsls (TypeScript/JavaScript) Configuration
return {
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	-- Ưu tiên tsconfig/jsconfig để bám đúng package có khai báo paths (@/) alias
	-- trong monorepo, trước khi rơi về package.json/.git.
	root_markers = {
		"tsconfig.json",
		"jsconfig.json",
		"package.json",
		".git",
	},
	settings = {
		typescript = {
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
			preferences = {
				jsxAttributeCompletionStyle = "auto",
				-- vtsls đọc key kiểu VS Code: "importModuleSpecifier" (KHÔNG phải
				-- "importModuleSpecifierPreference" của giao thức tsserver thô).
				-- "non-relative": luôn ưu tiên alias @/ theo paths trong tsconfig.
				importModuleSpecifier = "non-relative",
				importModuleSpecifierEnding = "minimal",
			},
			inlayHints = {
				enumMemberValues = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = false },
				propertyDeclarationTypes = { enabled = true },
				variableTypes = { enabled = false },
			},
		},
		javascript = {
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
			preferences = {
				jsxAttributeCompletionStyle = "auto",
				importModuleSpecifierPreference = "shortest",
				importModuleSpecifierEnding = "minimal",
			},
			inlayHints = {
				enumMemberValues = { enabled = true },
				functionLikeReturnTypes = { enabled = true },
				parameterNames = { enabled = "literals" },
				parameterTypes = { enabled = false },
				propertyDeclarationTypes = { enabled = true },
				variableTypes = { enabled = false },
			},
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
