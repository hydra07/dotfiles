-- ESLint Configuration
-- Role: lint + code action (fix on demand) only. Does NOT format on save
-- (Prettier/conform handles that) — avoids conflicts and lag when saving TS files.
return {
	root_markers = {
		".eslintrc",
		".eslintrc.js",
		".eslintrc.cjs",
		".eslintrc.json",
		".eslintrc.yaml",
		".eslintrc.yml",
		"eslint.config.js",
		"eslint.config.mjs",
		"eslint.config.cjs",
		"eslint.config.ts",
	},
	settings = {
		-- Correct key is "workingDirectory" (singular), object { mode = "auto" }.
		-- "auto" = use the workspace folder (root) as cwd -> resolver reads the
		-- root ./tsconfig.json correctly -> @/ resolves OK (matches CLI/VSCode behavior).
		-- Misspelling it "workingDirectories" makes the server ignore it -> cwd falls
		-- back to the file's directory -> import-x/no-unresolved false-flags '@/...'.
		workingDirectory = { mode = "auto" },
		format = false,
		-- onSave (not onType): typed-linting on this project takes ~3.4s per run, so
		-- onType would re-lint every keystroke -> backlog, plus format_after_save
		-- triggering it twice -> a stubborn 3-5s stall after saving. Instant type
		-- errors are already covered by ts7. ESLint only needs one run on save for
		-- its own rules (import-order/unused/sonarjs).
		run = "onSave",
		quiet = false,
		onIgnoredFiles = "off",
		problems = { shortenToSingleLine = false },
	},
	-- Override lspconfig's before_init: it sets workspaceFolder.uri to a raw path
	-- ("D:/dev/..."), which vscode-eslint fails to match against the document uri
	-- (file:///d:/...) -> mode "auto" falls back to the file's directory -> resolver
	-- can't see @/. Set the URI properly instead.
	before_init = function(_, config)
		local root_dir = config.root_dir
		if root_dir then
			config.settings = config.settings or {}
			config.settings.workspaceFolder = {
				uri = vim.uri_from_fname(root_dir),
				name = vim.fn.fnamemodify(root_dir, ":t"),
			}
		end
	end,
}
