return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "░" },
				untracked = { text = "▎" },
			},
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 1000,
				ignore_whitespace = false,
				virt_text_priority = 100,
			},
			current_line_blame_formatter = " <author> · <author_time:%R> · <summary>",
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns
				local keymaps = require("config.keymaps")

				-- Navigation
				keymaps.set_buffer("git_next_hunk", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, bufnr, { expr = true })

				keymaps.set_buffer("git_prev_hunk", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, bufnr, { expr = true })

				-- Actions
				keymaps.set_buffer("git_stage_hunk", gs.stage_hunk, bufnr)
				keymaps.set_buffer("git_reset_hunk", gs.reset_hunk, bufnr)
				keymaps.set_buffer("git_stage_hunk_visual", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, bufnr)
				keymaps.set_buffer("git_reset_hunk_visual", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, bufnr)
				keymaps.set_buffer("git_stage_buffer", gs.stage_buffer, bufnr)
				keymaps.set_buffer("git_undo_stage_hunk", gs.undo_stage_hunk, bufnr)
				keymaps.set_buffer("git_reset_buffer", gs.reset_buffer, bufnr)
				keymaps.set_buffer("git_preview_hunk", gs.preview_hunk, bufnr)
				keymaps.set_buffer("git_blame_line", function()
					gs.blame_line({ full = true })
				end, bufnr)
				keymaps.set_buffer("git_toggle_line_blame", gs.toggle_current_line_blame, bufnr)
				keymaps.set_buffer("git_diff_this", gs.diffthis, bufnr)
				keymaps.set_buffer("git_diff_this_tilde", function()
					gs.diffthis("~")
				end, bufnr)

				-- Text object
				keymaps.set_buffer("git_hunk_textobject", ":<C-U>Gitsigns select_hunk<CR>", bufnr)
			end,
		},
	},
}
