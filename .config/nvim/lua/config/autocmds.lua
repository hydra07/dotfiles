local function augroup(name)
	return vim.api.nvim_create_augroup("my_group_" .. name, { clear = true })
end
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 150,
		})
	end,
})

-- `nvim` or `nvim .` → Telescope file_browser
vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup("explorer_on_start"),
	callback = function()
		local arg = vim.fn.argv(0)
		local is_no_args = vim.fn.argc() == 0
		local is_directory = vim.fn.argc() == 1 and vim.fn.isdirectory(arg) == 1

		if is_no_args or is_directory then
			vim.defer_fn(function()
				local dir = vim.loop.cwd()
				if is_directory then
					dir = vim.fn.fnamemodify(arg, ":p")
					vim.cmd.cd(dir)
					local buf = vim.api.nvim_get_current_buf()
					if vim.api.nvim_buf_is_valid(buf) then
						pcall(vim.api.nvim_buf_delete, buf, { force = true })
					end
				end
				require("telescope").extensions.file_browser.file_browser({ path = dir })
			end, 30)
		end
	end,
})
