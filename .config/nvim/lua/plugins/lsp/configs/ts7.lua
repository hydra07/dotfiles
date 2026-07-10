-- ts7 — TypeScript 7 native (Go) làm LSP RIÊNG của editor.
--
-- Mô hình (giống VSCode): editor có TS engine riêng, ĐỘC LẬP với `typescript`
-- dependency của project. Ở đây engine là TS7 native global; project vẫn có thể
-- pin typescript@6 cho build/CI. Thứ duy nhất đọc từ project là tsconfig.json
-- (để hiểu compilerOptions + paths @/), còn engine chạy là TS7 của editor.
--
-- Binary: cài global `npm i -g @typescript/native-preview` (cung cấp `tsgo`).
-- Cùng 1 Go binary với `tsc` của typescript@7 stable, chỉ khác tên bin.
-- Bản thân binary tự nói LSP qua `--lsp --stdio` -> không cần viết host riêng.
--
-- Tự chứa hoàn toàn (không mượn base lspconfig) để KHÔNG bao giờ rơi vào
-- node_modules/.bin của project -> luôn dùng TS7 của editor.

-- Ưu tiên native .exe (standalone, không cần node, spawn ổn định trên Windows),
-- fallback về exepath trên PATH cho môi trường khác (WSL/Linux).
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
	-- Neo root vào tsconfig/jsconfig (chỗ có paths @/), rồi package.json/.git.
	root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
	settings = {
		typescript = {
			preferences = {
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
			preferences = {
				importModuleSpecifier = "non-relative",
				importModuleSpecifierEnding = "minimal",
			},
		},
	},
}
