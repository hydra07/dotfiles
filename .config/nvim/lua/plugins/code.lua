return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		opts = {
			notify_on_error = true,
			notify_no_formatters = true,
			formatters_by_ft = {
				sh = { "shfmt" },
				bash = { "shfmt" },
				fish = { "fish_indent" },
				lua = { "stylua" },
				-- stop_after_first = true: chỉ chạy formatter đầu tiên available
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				python = { "black" },
				go = { "gofumpt", "goimports-reviser", "golines" },
				rust = { "rustfmt" },
				json = { "prettierd" },
				yaml = { "prettierd" },
				markdown = { "prettierd" },
			},
			-- format_on_save as function: skip large files, guard against hangs
			format_on_save = function(bufnr)
				-- Skip files > 2000 lines to prevent formatter timeout
				local line_count = vim.api.nvim_buf_line_count(bufnr)
				if line_count > 2000 then
					return nil -- skip, don't format
				end
				-- Skip buffers without a file (scratch, terminal, etc.)
				local bufname = vim.api.nvim_buf_get_name(bufnr)
				if bufname == "" then
					return nil
				end
				return {
					timeout_ms = 800, -- short timeout: if formatter hangs, abort fast
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
