local keymaps = require("config.keymaps")

return {
	keys = {
		keymaps.bind("undo_history", "<cmd>Telescope undo<cr>"),
	},
}
