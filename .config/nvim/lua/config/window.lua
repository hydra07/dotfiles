local powershell = "powershell"
if vim.fn.executable("pwsh") == 1 then
	powershell = "pwsh"
end
local options = {
	shell = powershell,
	shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
	shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
	shellpipe = "2>&1 | Out-File -Encoding UTF8 %s",
	shellquote = "",
	shellxquote = "",
}
for option, value in pairs(options) do
	vim.opt[option] = value
end
vim.opt.fileencoding = "utf-8"
vim.scriptencoding = "utf-8"
vim.opt.clipboard = "unnamedplus"
if vim.fn.has("win32") == 1 then
	vim.g.clipboard = {
		name = "win32yank",
		copy = {
			["+"] = "win32yank.exe -i --crlf",
			["*"] = "win32yank.exe -i --crlf",
		},
		paste = {
			["+"] = "win32yank.exe -o --lf",
			["*"] = "win32yank.exe -o --lf",
		},
		cache_enabled = 0,
	}
end
