local keymaps = require("config.keymaps")

local function format_buffer()
	require("conform").format({ async = true, lsp_format = "fallback" }, function(err, did_edit)
		if err then
			vim.notify("Format failed: " .. err, vim.log.levels.ERROR, { title = "Conform" })
			return
		end
		if did_edit then
			vim.notify("Formatted buffer", vim.log.levels.INFO, { title = "Conform" })
		else
			vim.notify("No formatting changes", vim.log.levels.INFO, { title = "Conform" })
		end
	end)
end

return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			keymaps.bind("format_buffer", format_buffer),
			keymaps.bind("conform_info", "<cmd>ConformInfo<cr>"),
		},
		opts = {
			notify_on_error = true,
			notify_no_formatters = true,
			formatters_by_ft = {
				sh = { "shfmt" },
				bash = { "shfmt" },
				fish = { "fish_indent" },
				lua = { "stylua" },
				-- Prettier formats; ESLint only lints (don't mix both into the format
				-- chain — they conflict, and eslint_d runs synchronously and slowly on large TS projects).
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
				go = { "gofumpt", "goimports-reviser", "golines" },
				rust = { "rustfmt" },
				json = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
			},
			-- format_after_save as function: completely asynchronous and non-blocking!
			format_after_save = function(bufnr)
				-- Skip files > 3000 lines to prevent formatter timeout
				local line_count = vim.api.nvim_buf_line_count(bufnr)
				if line_count > 3000 then
					return nil -- skip, don't format
				end
				-- Skip buffers without a file (scratch, terminal, etc.)
				local bufname = vim.api.nvim_buf_get_name(bufnr)
				if bufname == "" then
					return nil
				end
				return {
					lsp_format = "fallback",
				}
			end,
			formatters = {
				shfmt = {
					prepend_args = { "-i", "2" },
				},
			},
		},
	},
}
