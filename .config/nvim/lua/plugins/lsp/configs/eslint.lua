-- ESLint Configuration
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
	},
	settings = {
		workingDirectories = { { directory = "." } },
		options = {
			cwd = vim.fn.getcwd(),
		},
		nodePath = "node_modules",
		format = true,
		run = "onSave",
		quiet = false,
		onIgnoredFiles = "off",
		problems = { shortenToSingleLine = false },
	},
}
