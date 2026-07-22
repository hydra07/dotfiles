return {
	{
		"MagicDuck/grug-far.nvim",
		cmd = "GrugFar",
		keys = {
			{
				"<leader>sr",
				function()
					local grug = require("grug-far")
					local ext = vim.fn.expand("%:e")
					grug.open({
						transient = true,
						prefills = {
							filesFilter = (ext and ext ~= "") and ("*." .. ext) or nil,
						},
					})
				end,
				mode = { "n", "v" },
				desc = "Search & Replace (Project)",
			},
		},
		opts = {
			headerMaxWidth = 80,
			icons = {
				enabled = true,
			},
		},
	},
}
