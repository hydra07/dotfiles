return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			{
				"windwp/nvim-ts-autotag",
				opts = {
					opts = {
						enable_close = true,
						enable_rename = true,
						enable_close_on_slash = true,
					},
				},
			},
		},
		config = function()
			local max_filesize = 1024 * 1024 -- 1MB
			local function is_large_file(bufnr)
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
				return ok and stats and stats.size > max_filesize
			end

			-- require("nvim-treesitter.install").compilers = { "zig" }
			require("nvim-treesitter").setup({
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"query",
					"typescript",
					"javascript",
					"tsx",
					"python",
					"rust",
					"go",
					"html",
					"css",
				},
				auto_install = true,
				highlight = {
					enable = true,
					disable = function(_, bufnr)
						return is_large_file(bufnr)
					end,
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true,
					disable = function(_, bufnr)
						return is_large_file(bufnr)
					end,
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "gnn",
						node_incremental = "grn",
						scope_incremental = "grc",
						node_decremental = "grm",
					},
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
						},
					},
				},
			})
		end,
	},
}
