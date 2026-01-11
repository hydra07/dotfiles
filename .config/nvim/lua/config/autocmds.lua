local function augroup(name)
	return vim.api.nvim_create_augroup("my_group_" .. name, { clear = true })
end
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch", -- Hoặc "Visual", hoặc màu Pink bạn thích
			timeout = 150, -- Thời gian nháy (ms)
		})
	end,
})
