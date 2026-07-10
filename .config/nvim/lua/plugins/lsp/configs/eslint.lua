-- ESLint Configuration
-- Vai trò: chỉ lint + code action (fix on demand). KHÔNG format trên save
-- (Prettier/conform lo format). Tránh xung đột & lag khi lưu file TS.
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
		-- Key ĐÚNG là "workingDirectory" (số ít), object { mode = "auto" }.
		-- "auto" = dùng workspace folder (root) làm cwd -> resolver đọc đúng
		-- ./tsconfig.json ở root -> @/ resolve OK (khớp behavior CLI/VSCode).
		-- Viết sai thành "workingDirectories" thì server bỏ qua -> cwd = thư mục
		-- file -> import-x/no-unresolved báo giả '@/...'.
		workingDirectory = { mode = "auto" },
		format = false,
		run = "onType",
		quiet = false,
		onIgnoredFiles = "off",
		problems = { shortenToSingleLine = false },
	},
	-- Ghi đè before_init của lspconfig: nó set workspaceFolder.uri = đường dẫn THÔ
	-- ("D:/dev/..."), khiến vscode-eslint không khớp document uri (file:///d:/...)
	-- -> mode "auto" rơi về thư mục file -> resolver mù @/. Set URI đúng chuẩn.
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
