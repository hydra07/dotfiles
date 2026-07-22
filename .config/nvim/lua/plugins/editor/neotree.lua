local keymaps = require("config.keymaps")

return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			keymaps.bind("toggle_explorer", "<cmd>Neotree toggle<cr>"),
		},
		opts = {
			filesystem = {
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
				},
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
			},
			window = {
				width = 30,
				mappings = {},
			},
		},
	},
}
