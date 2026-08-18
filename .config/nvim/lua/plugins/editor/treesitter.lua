return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			{ "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
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
		init = function()
			require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
				local filepath = vim.api.nvim_buf_get_name(tonumber(bufnr) or 0)
				local filename = vim.fn.fnamemodify(filepath, ":t")
				return string.match(filename, ".*mise.*%.toml$") ~= nil
			end, { force = true, all = false })
		end,
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
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]f"] = { query = "@function.outer", desc = "Next function start" },
							["]cl"] = { query = "@class.outer", desc = "Next class start" },
							["]a"] = { query = "@parameter.inner", desc = "Next parameter start" },
							["]o"] = { query = { "@conditional.outer", "@loop.outer" }, desc = "Next block start" },
						},
						goto_next_end = {
							["]F"] = { query = "@function.outer", desc = "Next function end" },
							["]Cl"] = { query = "@class.outer", desc = "Next class end" },
						},
						goto_previous_start = {
							["[f"] = { query = "@function.outer", desc = "Previous function start" },
							["[cl"] = { query = "@class.outer", desc = "Previous class start" },
							["[a"] = { query = "@parameter.inner", desc = "Previous parameter start" },
							["[o"] = { query = { "@conditional.outer", "@loop.outer" }, desc = "Previous block start" },
						},
						goto_previous_end = {
							["[F"] = { query = "@function.outer", desc = "Previous function end" },
							["[Cl"] = { query = "@class.outer", desc = "Previous class end" },
						},
					},
				},
			})
		end,
	},
}
