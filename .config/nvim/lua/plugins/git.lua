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

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Next Git Change" })

				map("n", "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, desc = "Prev Git Change" })

				-- Actions
				map("n", "<leader>ghs", gs.stage_hunk, { desc = "Stage Hunk" })
				map("n", "<leader>ghr", gs.reset_hunk, { desc = "Reset Hunk" })
				map("v", "<leader>ghs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "Stage Selected Hunk" })
				map("v", "<leader>ghr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, { desc = "Reset Selected Hunk" })
				map("n", "<leader>ghS", gs.stage_buffer, { desc = "Stage Buffer" })
				map("n", "<leader>ghu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
				map("n", "<leader>ghR", gs.reset_buffer, { desc = "Reset Buffer" })
				map("n", "<leader>ghp", gs.preview_hunk, { desc = "Preview Hunk Inline" })
				map("n", "<leader>ghb", function()
					gs.blame_line({ full = true })
				end, { desc = "Git Blame Line" })
				map("n", "<leader>ghB", gs.toggle_current_line_blame, { desc = "Toggle Git Blame Line" })
				map("n", "<leader>ghd", gs.diffthis, { desc = "Diff This" })
				map("n", "<leader>ghD", function()
					gs.diffthis("~")
				end, { desc = "Diff This ~" })

				-- Text object
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Git Hunk" })
			end,
		},
	},
}
