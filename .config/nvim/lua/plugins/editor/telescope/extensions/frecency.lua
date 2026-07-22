local keymaps = require("config.keymaps")

return {
	keys = {
		keymaps.bind("find_files_frecency", "<cmd>Telescope frecency workspace=CWD<cr>"),
	},
}
