-- Basedpyright (Python) Configuration
local function usable(p)
	if p and p ~= "" and vim.fn.executable(p) == 1 then
		return p
	end
end

-- Chọn interpreter python theo thứ tự: .venv project > mise (theo project) > system.
-- PHẢI set trước khi server initialize, nếu không basedpyright tự dò và hay vớ nhầm
-- bản không tồn tại (vd python3.14t.exe free-threaded) -> crash exit 103.
local function resolve_python(root)
	root = root or vim.fn.getcwd()
	local p = usable(root .. "/.venv/Scripts/python.exe") or usable(root .. "/.venv/bin/python")
	if not p and vim.fn.executable("mise") == 1 then
		local ok, res = pcall(function()
			return vim.system({ "mise", "which", "python" }, { cwd = root, text = true }):wait()
		end)
		if ok and res and res.code == 0 then
			p = usable(vim.trim(res.stdout or ""))
		end
	end
	return p or usable(vim.fn.exepath("python")) or usable(vim.fn.exepath("python3"))
end

return {
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local root = vim.fs.root(fname, { ".venv", "pyproject.toml", "setup.py", ".git" })
		on_dir(root or vim.fn.getcwd())
	end,

	-- before_init: chạy TRƯỚC initialize -> pythonPath sẵn sàng khi basedpyright
	-- hỏi workspace/configuration lúc probe interpreter.
	before_init = function(_, config)
		local root = config.root_dir or vim.fn.getcwd()
		local python_path = resolve_python(root)
		config.settings = config.settings or {}
		config.settings.python = config.settings.python or {}
		if python_path then
			config.settings.python.pythonPath = python_path
		end
		config.settings.basedpyright = config.settings.basedpyright or {}
		config.settings.basedpyright.analysis = config.settings.basedpyright.analysis or {}
		config.settings.basedpyright.analysis.extraPaths = { root }
	end,

	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "basic", -- "off", "basic", "standard", "strict"
				autoImportCompletions = true,
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "openFilesOnly", -- crucial optimization for large projects
				inlayHints = {
					variableTypes = true,
					functionReturnTypes = true,
					callArgumentNames = true,
				},
			},
		},
	},
}
