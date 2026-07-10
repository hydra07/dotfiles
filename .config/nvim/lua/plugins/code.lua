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
				-- Prettier lo format; ESLint chỉ lint (đừng trộn 2 thằng vào format chain
				-- vì chúng đánh nhau + eslint_d chạy đồng bộ rất chậm trên project TS lớn).
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
	{
		"jmbuhr/otter.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			vim.api.nvim_create_autocmd({ "FileType" }, {
				pattern = { "toml" },
				group = vim.api.nvim_create_augroup("EmbedToml", {}),
				callback = function()
					require("otter").activate()
				end,
			})
		end,
	},
}
